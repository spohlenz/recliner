require 'active_model'

module Recliner
  class Document
    # The Recliner::Database object used by the current instance
    attr_reader :database
    
    # New objects can be instantiated as either empty (pass no construction parameter) or pre-set with
    # attributes but not yet saved (pass a hash with key names matching the associated properties).
    def initialize(attributes={})
      self.attributes = attributes

      @database = self.class.database
      @new_record = true

      yield self if block_given?

      callback(:after_initialize) if respond_to?(:after_initialize)
    end

    # :call-seq:
    #   save(perform_validation = true)
    #
    # Saves the document instance.
    #
    # If the document is new a document gets created in the database, otherwise
    # the existing document gets updated.
    #
    # If +perform_validation+ is true validations run. If any of them fail
    # the action is cancelled and +save+ returns +false+. If the flag is
    # false validations are bypassed altogether. See
    # Recliner::Validations for more information. 
    #
    # There's a series of callbacks associated with +save+. If any of the
    # <tt>before_*</tt> callbacks return +false+ the action is cancelled and
    # +save+ returns +false+. See Recliner::Callbacks for further
    # details.
    def save
      create_or_update
    rescue DocumentNotSaved
      false
    end
    
    # Saves the model.
    #
    # If the model is new a document gets created in the database, otherwise
    # the existing document gets updated.
    #
    # With <tt>save!</tt> validations always run. If any of them fail
    # Recliner::DocumentInvalid gets raised. See Recliner::Validations
    # for more information. 
    #
    # There's a series of callbacks associated with <tt>save!</tt>. If any of
    # the <tt>before_*</tt> callbacks return +false+ the action is cancelled
    # and <tt>save!</tt> raises Recliner::DocumentNotSaved. See
    # Recliner::Callbacks for further details.
    def save!
      create_or_update || raise(DocumentNotSaved)
    end
    
    # Updates all the attributes from the passed-in Hash and saves the document. If the object is invalid, the saving will
    # fail and false will be returned.
    def update_attributes(attrs)
      self.attributes = attrs and save
    end

    # Deletes the document in the database and marks the instance as
    # read-only to reflect that no changes should be made (since they
    # can't be persisted). Returns the deleted instance.
    #
    # To enforce the object's +before_destroy+ and +after_destroy+
    # callbacks, Observer methods, or any <tt>:dependent</tt> association
    # options, use <tt>#destroy</tt>.
    def delete
      begin
        database.delete("#{id}?rev=#{rev}") unless new_record?
      rescue DocumentNotFound
        # OK - document is already deleted
      end
      
      read_only!
      self
    end
    
    # Deletes the document in the database and marks the instance as
    # read-only to reflect that no changes should be made (since they
    # can't be persisted).
    def destroy
      delete
    end
    
    # Returns true if this object hasn't been saved yet -- that is, a record for the object doesn't exist yet; otherwise, returns false.
    def new_record?
      @new_record || false
    end
    
    # Marks this document as read only.
    def read_only!
      attributes.freeze
    end
    
    # Returns true if this document has been marked as read only; otherwise, returns false.
    def read_only?
      attributes.frozen?
    end
  
    # Compares documents for equality. Two documents are considered equal if they share the same document id and class.
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
      
      if id_changed? && !new_record?
        database.delete(id_was, :rev => rev)
      end
      
      self.rev = result['rev']
      
      @new_record = false
      
      true
    end
  
    module ClassMethods
      # Loads one or more documents from the database given their document IDs.
      # If a document does not exist, nil will be returned.
      #
      # ==== Examples
      #
      #   >> TestDocument.load('some-document-id')         # returns the object with id 'some-document-id'
      #   >> TestDocument.load('missing-document')         # returns nil for missing documents
      #   >> TestDocument.load('document-1', 'document-2') # returns an array of objects with ids 'document-1', 'document-2'
      def load(*ids)
        load_ids(ids, false)
      end
      
      # Loads one or more documents from the database given their document IDs.
      # If a document does not exist, a Recliner::DocumentNotFound exception will be raised.
      #
      # ==== Examples
      #
      #   >> TestDocument.load!('some-document-id')         # returns the object with id 'some-document-id'
      #   >> TestDocument.load!('missing-document')         # raises Recliner::DocumentNotFound exception for missing documents
      #   >> TestDocument.load!('document-1', 'document-2') # returns an array of objects with ids 'document-1', 'document-2'
      def load!(*ids)
        load_ids(ids, true)
      end

      # Creates an object and saves it to the database, if validations pass.
      # The resulting object is returned whether the object was saved successfully to the database or not.
      #
      # The +attributes+ parameter can be either be a Hash or an Array of Hashes.  These Hashes describe the
      # attributes on the objects that are to be created.
      #
      # ==== Examples
      #
      #   # Create a single new object
      #   User.create(:first_name => 'Jamie')
      #
      #   # Create a single object and pass it into a block to set other attributes.
      #   User.create(:first_name => 'Jamie') do |u|
      #     u.is_admin = false
      #   end
      def create(attributes={})
        returning new(attributes) do |doc|
          yield doc if block_given?
          doc.save
        end
      end

      # Creates an object just like create but calls save! instead of save
      # so an exception is raised if the document is invalid.
      def create!(attributes={})
        returning new(attributes) do |doc|
          yield doc if block_given?
          doc.save!
        end
      end

      # #
      # def destroy(id)
      #   if id.is_a?(Array)
      #     id.map { |i| destroy(i) }
      #   else
      #     load(id).destroy
      #   end
      # end
      # 
      # #
      # def delete(id)
      #   if id.is_a?(Array)
      #     id.map { |i| delete(i) }
      #   else
      #     # We have to instantiate the document to know its revision
      #     load(id).delete
      #   end
      # end

      # Set a new database URI to use for this class and subclasses.
      def use_database!(uri)
        @default_database = nil
        write_inheritable_attribute(:database_uri, uri)
      end
  
      # The Recliner::Database object to use for this class.
      def database
        Thread.current["#{name}_database"] || default_database
      end
      
      # The default database to use for this class, based on the URI given to use_database!.
      def default_database
        @default_database ||= Database.new(read_inheritable_attribute(:database_uri))
      end
  
      # Sets a database for a block, that all objects of this type created inside the block should use.
      def with_database(db)
        Thread.current["#{name}_database"] = db
        
        yield
      ensure
        Thread.current["#{name}_database"] = nil
      end
      
      #
      def instantiate_from_database(attrs)
        unless attrs['class'] && (self == Document || attrs['class'] == name)
          raise DocumentNotFound
        end
        
        klass = attrs['class'].constantize
        
        returning(klass.new) do |doc|
          klass.properties.each do |name, property|
            doc.write_attribute(property.name, property.type.from_couch(attrs[property.as]))
          end
          
          doc.instance_variable_set("@new_record", false)
          doc.send(:changed_attributes).clear
          doc.send(:callback, :after_load) if doc.respond_to?(:after_load)
        end
      end

      def self_and_descendants_from_recliner#:nodoc:
        klass = self
        classes = [klass]
        while klass.superclass != Document
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
      # Default scope of the translation is recliner.models
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
    extend Document::ClassMethods
    
    use_database! 'http://localhost:5984/recliner-default'

    include Properties
    include Properties::Map
    include Properties::Set

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
    
    extend Associations::BelongsTo
    
    include Timestamps
    include PrettyInspect

    include ActiveModel::Conversion
    extend ActiveModel::Naming
  end
end
