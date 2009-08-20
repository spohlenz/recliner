module Recliner
  module AttributeMethods
    module Read
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix ""
      end
      
      def read_attribute(name)
        attributes[name.to_s]
      end
      
      # def [](name)
      #   read_attribute(name)
      # end
      
    private
      def attribute(attribute_name)
        read_attribute(attribute_name)
      end
    end
  end
end