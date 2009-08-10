module Recliner
  module AttributeMethods
    module Write
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix "="
      end
      
      #
      def write_attribute(name, value)
        attributes[property(name).as] = value if property(name)
        value
      end
      
    private
      # Handle *= for method_missing.
      def attribute=(attribute_name, value)
        write_attribute(attribute_name, value)
      end
    end
  end
end
