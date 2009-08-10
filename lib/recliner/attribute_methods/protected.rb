module Recliner
  module AttributeMethods
    module Protected
      extend ActiveSupport::Concern
      
      included do
        attr_protected :class
      end
      
      module ClassMethods
        def property(name, *args, &block)
          options = args.extract_options!
          
          super(name, *args << options, &block)
          
          attr_protected(name) if options[:protected]
        end
        
        #
        def attr_protected(*attrs)
          write_inheritable_attribute(:attr_protected, attrs.map { |a| a.to_s } + (protected_attributes || []))
        end

        #
        def protected_attributes
          read_inheritable_attribute(:attr_protected)
        end
      end
      
      def attributes=(attrs)
        super(remove_protected_attributes(attrs))
      end
    
    private
      def remove_protected_attributes(attrs)
        attrs.reject { |key, value| self.class.protected_attributes.include?(key.to_s) }
      end
    end
  end
end
