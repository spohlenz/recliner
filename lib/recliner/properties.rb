require 'uuid'
require 'active_support/core_ext/array/extract_options'

module Recliner
  module Properties#:nodoc:
    autoload :Map, 'recliner/properties/map'
    autoload :Set, 'recliner/properties/set'
    
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :properties
      self.properties = ActiveSupport::OrderedHash.new
      
      property :id,  String, :as => '_id', :default => lambda { |doc| generate_guid }
      property :rev, String, :as => '_rev'
    end
    
    module ClassMethods
      # Defines a property on the document.
      # Expects a name (a symbol), type (class) and an (optional) options hash.
      #
      # ==== Supported options:
      #
      # [:default]
      #   Default value for property, which is set on new instances.
      #   May be a proc (which takes the instance as its argument).
      # [:as]
      #   The internal name to use when saving the property to couch format.
      # [:protected]
      #   Sets the property to be protected from mass-assignment. See attr_protected.
      # [:accessible]
      #   Sets the property to be accessible to mass-assignment. See attr_accessible.
      #
      # ==== Example
      #
      #   property :name, String       # Basic property using standard type
      #   property :address, Address   # Custom types must implement from_couch/to_couch methods
      #
      #   property :language, String, :default => 'English'    # New instances will have default language 'English'
      #   property :special, Integer, :as => '_internal_name'  # Attribute will be stored internally as '_internal_name'
      #
      def property(name, *args, &block)
        options = args.extract_options!
        type = args.first
        
        if type
          prop = Property.new(name.to_s, type, (options[:as] || name).to_s, options[:default])
          properties[name.to_sym] = prop
        # elsif block_given?
        #   raise 'Not yet supported'
        else
          raise ArgumentError.new('Either a type or block must be provided')
        end
      end
      
      # Returns a hash of all defined properties except for the internal properties +id+ and +rev+.
      def model_properties
        properties.reject { |name, property| [:id, :rev].include?(name) }
      end
      
    protected
      # Generates a unique identifier for new documents
      def generate_guid
        UUID.generate
      end
    end
    
  private
    def property(name)
      properties[name.to_sym]
    end
  end
end
