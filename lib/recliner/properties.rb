require 'uuid'

module Recliner
  class Property < Struct.new(:name, :type, :as, :default)
    def default_value(instance)
      default.respond_to?(:call) ? default.call(instance) : default
    end
  end
  
  module Properties
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :properties
      self.properties = {}
      
      property :id,  String, :as => '_id', :default => lambda { generate_guid }
      property :rev, String, :as => '_rev'
    end
    
    module ClassMethods
      #
      def property(name, *args, &block)
        options = args.extract_options!
        type = args.first
        
        if type
          prop = Property.new(name.to_s, type, (options[:as] || name).to_s, options[:default])
          properties[name.to_sym] = prop
      #   elsif block_given?
      #     raise 'Not yet supported'
        else
          raise ArgumentError.new('Either a type or block must be provided')
        end
      end
      
      # Returns all defined properties except for id and rev
      def model_properties
        properties.reject { |name, property| [:id, :rev].include?(name) }
      end
      
    protected
      # Unique ID generation for new documents
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
