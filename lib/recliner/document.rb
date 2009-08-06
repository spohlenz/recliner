require 'active_support/core_ext'
require 'active_model'

module Recliner
  class Document
    undef_method :id
    
    class_inheritable_accessor :database_uri
    self.database_uri = 'http://localhost:5984/recliner-default'
    
    attr_reader :database
    
    def initialize(attributes={})
      self.class.default_attributes(self).each do |property, default|
        write_attribute(property, default)
      end
      
      self.attributes = attributes
      
      @database = self.class.database
      @new_record = true
      
      yield self if block_given?
      
      callback(:after_initialize) if respond_to?(:after_initialize)
    end
    
    
    # Define core properties
    
    include Properties, CompositeProperties
  
    property :id,  String, :as => '_id', :default => lambda { generate_guid }
    property :rev, String, :as => '_rev'
  
  
    # Define default views
    
    include Views
    
    view :all
    
    default_order :id
    default_conditions :class => '#{name}'
    
    #
    # Example views
    #
    # view :by_title, :order => :title
    # view :published, :conditions => { :published => true }
    # view :custom_map, :map => "emit(null, doc)"          # function is optional
    # view :custom_reduce, :map => "function(doc) { emit(doc.tag, doc); }",
    #                      :reduce => "function(keys, values) { return sum(values); }"
    #
    #
    # Overrides default order for 'all' view
    #
    # default_order :title
    #
  
    # Special case for id setter as old document needs to be deleted if the id is changed
    def id=(new_id)
      @old_id = id unless new_record?
      write_attribute(:id, new_id)
    end
  
    # If the doc id has changed, we need to delete the old document when saving
    def id_changed?
      !new_record? && @old_id && @old_id != id
    end
  
    #
    def save
      create_or_update
    end
  
    #
    def save!
      save || raise(DocumentNotSaved)
    end
    
    #
    def destroy
      delete
    end
    
    #
    def delete
      database.delete("#{id}?rev=#{rev}")
      self
    end
    
    # Returns true if this object hasn't been saved yet -- that is, a record for the object doesn't exist yet; otherwise, returns false.
    def new_record?
      @new_record || false
    end
  
    # Two documents are considered equal if they share the same document id and class
    def ==(other)
      other.class == self.class && other.id == self.id
    end
    
  private
    def create_or_update
      result = new_record? ? create : update
      result != false
    end
    
    # create and update are separate methods so that different callbacks can be applied to each
    
    def create
      save_to_database
    end
    
    def update
      save_to_database
    end
    
    def save_to_database
      result = database.put(id, to_couch)
      database.delete("#{@old_id}?rev=#{rev}") if id_changed?
      
      self.id = result['id']
      self.rev = result['rev']
      
      @new_record = false
      
      true
    rescue StaleRevisionError
      false
    end
    
    class << self
      #
      def load(*ids)
        load_ids(ids, false)
      end
      
      #
      def load!(*ids)
        load_ids(ids, true)
      end
      
      #
      def first
        all(:limit => 1).first
      end
      
      #
      def last
        all(:limit => 1, :descending => true).first
      end
      
      #
      def create(attributes={})
        returning new(attributes) do |doc|
          doc.save
        end
      end
      
      #
      def create!(attributes={})
        returning new(attributes) do |doc|
          doc.save!
        end
      end
      
      #
      def destroy(id)
        if id.is_a?(Array)
          id.map { |i| destroy(i) }
        else
          load(id).destroy
        end
      end
      
      #
      def delete(id)
        if id.is_a?(Array)
          id.map { |i| delete(i) }
        else
          load(id).delete
        end
      end
      
      #
      def use_database!(uri)
        @default_database = nil
        self.database_uri = uri
      end
      
      #
      def database
        Thread.current["#{name}_database"] || default_database
      end
      
      #
      def with_database(db)
        Thread.current["#{name}_database"] = db
        
        yield
      ensure
        Thread.current["#{name}_database"] = nil
      end
      
      def instantiate_from_database(attrs)
        klass = attrs['class'].constantize
      
        returning(klass.new) do |record|
          klass.properties.each do |name, property|
            record[property.name] = property.type.from_couch(attrs[property.as])
          end
        
          record.instance_variable_set("@new_record", false)
          record.send(:callback, :after_load) if record.respond_to?(:after_load)
        end
      end
      
      def self_and_descendants_from_recliner#nodoc:
        klass = self
        classes = [klass]
        while klass != klass.base_class
          classes << klass = klass.superclass
        end
        classes
      rescue
        [self]
      end
      
      # Transforms attribute key names into a more humane format, such as "First name" instead of "first_name". Example:
      #   Person.human_attribute_name("first_name") # => "First name"
      # This used to be deprecated in favor of humanize, but is now preferred, because it automatically uses the I18n
      # module now.
      # Specify +options+ with additional translating options.
      def human_attribute_name(attribute_key_name, options = {})
        defaults = self_and_descendants_from_recliner.map do |klass|
          :"#{klass.name.underscore}.#{attribute_key_name}"
        end
        defaults << options[:default] if options[:default]
        defaults.flatten!
        defaults << attribute_key_name.humanize
        options[:count] ||= 1
        I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:recliner, :attributes]))
      end
      
      # Transform the modelname into a more humane format, using I18n.
      # By default, it will underscore then humanize the class name (BlogPost.human_name #=> "Blog post").
      # Default scope of the translation is activerecord.models
      # Specify +options+ with additional translating options.
      def human_name(options = {})
        defaults = self_and_descendants_from_recliner.map do |klass|
          :"#{klass.name.underscore}"
        end
        defaults << self.name.underscore.humanize
        I18n.translate(defaults.shift, {:scope => [:recliner, :models], :count => 1, :default => defaults}.merge(options))
      end
    
    private
      def load_ids(ids, raise_exceptions=false)
        if ids.size == 1
          load_single(ids.first, raise_exceptions)
        else
          load_multiple(ids, raise_exceptions)
        end
      end
      
      def load_single(id, raise_exceptions=false)
        attrs = database.get(id)
        instantiate_from_database(attrs)
      rescue Recliner::DocumentNotFound => e
        raise e if raise_exceptions
        nil
      end
    
      def load_multiple(ids, raise_exceptions=false)
        result = database.post('_all_docs?include_docs=true', { :keys => ids })
        result['rows'].map { |row|
          if row['doc'] && row['doc']['class'] == name
            instantiate_from_database(row['doc'])
          else
            raise Recliner::DocumentNotFound if raise_exceptions
            nil
          end
        }
      end
      
      def default_database
        @default_database ||= Recliner::Database.new(database_uri)
      end
    end
  end
  
  Document.class_eval do
    include Validations
    include Callbacks
    include Associations
    include Timestamps
    include PrettyInspect
    
    include ActiveModel::Conversion
  end
end
