module Recliner
  module AttributeMethods
    module Protected
      extend ActiveSupport::Concern
      
      module ClassMethods
        def property(name, *args, &block)
          options = args.extract_options!
          
          super(name, *args << options, &block)
          
          attr_protected(name) if options[:protected]
          attr_accessible(name) if options[:accessible]
        end
        
        #
        def attr_protected(*attrs)
          write_inheritable_attribute(:attr_protected, attrs.map { |a| a.to_s } + protected_attributes)
        end
        
        #
        def attr_accessible(*attrs)
          write_inheritable_attribute(:attr_accessible, attrs.map { |a| a.to_s } + accessible_attributes)
        end
        
        #
        def protected_attributes
          read_inheritable_attribute(:attr_protected) || []
        end
        
        #
        def accessible_attributes
          read_inheritable_attribute(:attr_accessible) || []
        end
      end
      
      def attributes=(attrs)
        super(remove_protected_attributes(attrs))
      end
    
    private
      def remove_protected_attributes(attrs)
        if self.class.accessible_attributes.empty?
          attrs.reject { |k, v| self.class.protected_attributes.include?(k.to_s) }
        else
          attrs.reject { |k, v| !self.class.accessible_attributes.include?(k.to_s) }
        end
      end
    end
  end
end
