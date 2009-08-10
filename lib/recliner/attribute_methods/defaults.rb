module Recliner
  module AttributeMethods
    module Defaults
      extend ActiveSupport::Concern
      
      included do
        alias_method_chain :initialize, :defaults
      end
      
      module ClassMethods
        def default_attributes(instance)
          result = {}
          
          properties.each do |name, property|
            result[name] = property.default_value(instance) unless name == :rev
          end
          
          result.with_indifferent_access
        end
      end
      
      def initialize_with_defaults(attributes={})
        self.class.default_attributes(self).each do |property, default|
          write_attribute(property, default)
        end
        
        initialize_without_defaults(attributes)
      end
    end
  end
end
