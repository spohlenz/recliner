require 'active_model'

module Recliner
  class Document
    def initialize(attributes={})
      self.attributes = attributes

      # @database = self.class.database
      @new_record = true

      yield self if block_given?

      callback(:after_initialize) if respond_to?(:after_initialize)
    end
    
  #   # Special case for id setter as old document needs to be deleted if the id is changed
  #   def id=(new_id)
  #     @old_id ||= id unless new_record?
  #     write_attribute(:id, new_id)
  #   end
  # 
  #   # If the doc id has changed, we need to delete the old document when saving
  #   def id_changed?
  #     !new_record? && @old_id && @old_id != id
  #   end
  # 
  #   #
    def save
      create_or_update
    rescue StaleRevisionError
      false
    end
    
    def save!
      create_or_update
    end
    
  #   def update_attributes(attrs)
  #     self.attributes = attrs and save
  #   end

    #
    def destroy
      delete
    end

    #
    def delete
      begin
        database.delete("#{id}?rev=#{rev}") unless new_record?
      rescue DocumentNotFound
        # OK - document is already deleted
      end
      
      read_only!
      self
    end
    
    # Returns true if this object hasn't been saved yet -- that is, a record for the object doesn't exist yet; otherwise, returns false.
    def new_record?
      @new_record || false
    end
    
    # Marks this document as read only.
    def read_only!
      attributes.freeze
    end
    
    # Returns true if this document is read only.
    def read_only?
      attributes.frozen?
    end
  
    # Two documents are considered equal if they share the same document id and class.
    def ==(other)
      other.class == self.class && other.id == self.id
    end
  
    def database
      self.class.database
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
      
      # if id_changed?
      #   database.delete("#{@old_id}?rev=#{rev}")
      #   @old_id = nil
      # end
      
      self.rev = result['rev']
      
      @new_record = false
      
      true
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
  
  #     #
  #     def first
  #       all(:limit => 1).first
  #     end
  #     
  #     #
  #     def last
  #       all(:limit => 1, :descending => true).first
  #     end

      #
      def create(attributes={})
        returning new(attributes) do |doc|
          yield doc if block_given?
          doc.save
        end
      end

      #
      def create!(attributes={})
        returning new(attributes) do |doc|
          yield doc if block_given?
          doc.save!
        end
      end

  #     #
  #     def destroy(id)
  #       if id.is_a?(Array)
  #         id.map { |i| destroy(i) }
  #       else
  #         load(id).destroy
  #       end
  #     end
  #     
  #     #
  #     def delete(id)
  #       if id.is_a?(Array)
  #         id.map { |i| delete(i) }
  #       else
  #         # We have to instantiate the document to know its revision
  #         load(id).delete
  #       end
  #     end

      #
      def use_database!(uri)
        @default_database = nil
        write_inheritable_attribute(:database_uri, uri)
      end
  
      # Access the Recliner::Database object in use by this class
      def database
        #Thread.current["#{name}_database"] || default_database
        default_database
      end
      
      def default_database
        @default_database ||= Database.new(read_inheritable_attribute(:database_uri))
      end
  
  #     #
  #     def with_database(db)
  #       Thread.current["#{name}_database"] = db
  #       
  #       yield
  #     ensure
  #       Thread.current["#{name}_database"] = nil
  #     end

      def instantiate_from_database(attrs)
        raise DocumentNotFound if attrs['class'] != name
        
        klass = attrs['class'].constantize
        
        returning(klass.new) do |doc|
          klass.properties.each do |name, property|
            doc.write_attribute(property.name, property.type.from_couch(attrs[property.as]))
          end
          
          doc.instance_variable_set("@new_record", false)
          doc.send(:callback, :after_load) if doc.respond_to?(:after_load)
        end
      end

  #     def self_and_descendants_from_recliner#nodoc:
  #       klass = self
  #       classes = [klass]
  #       while klass != klass.base_class
  #         classes << klass = klass.superclass
  #       end
  #       classes
  #     rescue
  #       [self]
  #     end
  #     
  #     # Transforms attribute key names into a more humane format, such as "First name" instead of "first_name". Example:
  #     #   Person.human_attribute_name("first_name") # => "First name"
  #     # This used to be deprecated in favor of humanize, but is now preferred, because it automatically uses the I18n
  #     # module now.
  #     # Specify +options+ with additional translating options.
  #     def human_attribute_name(attribute_key_name, options = {})
  #       defaults = self_and_descendants_from_recliner.map do |klass|
  #         :"#{klass.name.underscore}.#{attribute_key_name}"
  #       end
  #       defaults << options[:default] if options[:default]
  #       defaults.flatten!
  #       defaults << attribute_key_name.humanize
  #       options[:count] ||= 1
  #       I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:recliner, :attributes]))
  #     end
  #     
  #     # Transform the modelname into a more humane format, using I18n.
  #     # By default, it will underscore then humanize the class name (BlogPost.human_name #=> "Blog post").
  #     # Default scope of the translation is activerecord.models
  #     # Specify +options+ with additional translating options.
  #     def human_name(options = {})
  #       defaults = self_and_descendants_from_recliner.map do |klass|
  #         :"#{klass.name.underscore}"
  #       end
  #       defaults << self.name.underscore.humanize
  #       I18n.translate(defaults.shift, {:scope => [:recliner, :models], :count => 1, :default => defaults}.merge(options))
  #     end

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
        result = database.post('_all_docs', { :keys => ids }, { :include_docs => true })
        result['rows'].map { |row|
          if row['doc'] && row['doc']['class'] == name
            instantiate_from_database(row['doc'])
          else
            raise Recliner::DocumentNotFound if raise_exceptions
            nil
          end
        }
      end
    end
  end
  
  Document.class_eval do
    use_database! 'http://localhost:5984/recliner-default'

    include Properties
    include Properties::Map

    include AttributeMethods
    include AttributeMethods::Read
    include AttributeMethods::Write
    include AttributeMethods::Query
    include AttributeMethods::BeforeTypeCast
    include AttributeMethods::Defaults
    include AttributeMethods::Protected
    include AttributeMethods::Dirty

    include Validations
    include Callbacks

    include Views
  #   include Associations
  
    include Timestamps
    include PrettyInspect

    include ActiveModel::Conversion
    extend ActiveModel::Naming
  end
end
