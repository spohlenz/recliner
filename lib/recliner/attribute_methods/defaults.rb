module Recliner
  module AttributeMethods
    module Defaults
      extend ActiveSupport::Concern
      
      included do
        alias_method_chain :initialize, :defaults
      end
      
      def initialize_with_defaults(attributes={}, &block)
        default_attributes.each do |property, default|
          write_attribute(property, default)
        end
        
        initialize_without_defaults(attributes, &block)
      end
    
    private
      def default_attributes
        result = {}
        
        properties.each do |name, property|
          result[name] = property.default_value(self) unless name == :rev
        end
        
        result
      end
    end
  end
end
