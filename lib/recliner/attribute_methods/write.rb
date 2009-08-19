module Recliner
  module AttributeMethods
    module Write
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix "="
      end
      
      #
      def write_attribute(name, value)
        attributes[name.to_s] = value
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
