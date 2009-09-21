require 'active_support/core_ext/hash/indifferent_access'

module Recliner
  module AttributeMethods
    module BeforeTypeCast
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix "_before_type_cast"
      end
      
      # Returns an attribute value before typecasting.
      def read_attribute_before_type_cast(name)
        if prop = property(name)
          attributes_before_type_cast[prop.as]
        else
          attributes_before_type_cast[name.to_s]
        end
      end
      
      # Returns a hash of attributes before typecasting.
      def attributes_before_type_cast
        @attributes_before_type_cast ||= {}.with_indifferent_access
      end
      
      def write_attribute(name, value)#:nodoc:
        if prop = property(name)
          attributes_before_type_cast[prop.as] = value
        else
          attributes_before_type_cast[name.to_s] = value
        end
        
        super
      end
      
    private
      def attribute_before_type_cast(attribute_name)
        read_attribute_before_type_cast(attribute_name)
      end
    end
  end
end
