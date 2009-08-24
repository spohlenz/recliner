module Recliner
  module AttributeMethods
    module Write
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix "="
      end
      
      #
      def write_attribute(name, value)
        if prop = property(name)
          attributes[prop.as] = prop.type_cast(value)
        else
          attributes[name.to_s] = value
        end
        
        value
      end
      
      # #
      # def []=(name, value)
      #   write_attribute(name, value)
      # end
      
    private
      # Handle *= for method_missing.
      def attribute=(attribute_name, value)
        write_attribute(attribute_name, value)
      end
    end
  end
end
