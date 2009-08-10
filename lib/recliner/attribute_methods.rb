module Recliner
  module AttributeMethods
    autoload :Read,      'recliner/attribute_methods/read'
    autoload :Write,     'recliner/attribute_methods/write'
    autoload :Query,     'recliner/attribute_methods/query'
    autoload :Dirty,     'recliner/attribute_methods/dirty'
    autoload :Defaults,  'recliner/attribute_methods/defaults'
    autoload :Protected, 'recliner/attribute_methods/protected'
    
    extend ActiveSupport::Concern
    
    include ActiveModel::AttributeMethods
    
    module ClassMethods
      # Generates all the attribute related methods for defined properties
      # accessors, mutators and query methods.
      def define_attribute_methods
        super(properties.keys)
      end
    end
    
    #
    def attributes
      @attributes ||= {}.with_indifferent_access
    end
    
    #
    def attributes=(attrs)
      attrs.each do |key, value|
        self.send("#{key}=", value)
      end
    end
    
    #
    def [](name)
      read_attribute(name)
    end
    
    #
    def []=(name, value)
      write_attribute(name, value)
    end
    
    def method_missing(method_id, *args, &block)
      # If we haven't generated any methods yet, generate them, then
      # see if we've created the method we're looking for.
      if !self.class.attribute_methods_generated?
        self.class.define_attribute_methods
        method_name = method_id.to_s
        
        guard_private_attribute_method!(method_name, args)
        
        if self.class.generated_attribute_methods.instance_methods.include?(method_name)
          return self.send(method_id, *args, &block)
        end
      end
      
      super
    end
    
  private
    def attributes_with_class
      attributes.merge(:class => self.class.name)
    end
  end
end
