module Recliner
  module AttributeMethods
    autoload :Read,           'recliner/attribute_methods/read'
    autoload :Write,          'recliner/attribute_methods/write'
    autoload :Query,          'recliner/attribute_methods/query'
    autoload :BeforeTypeCast, 'recliner/attribute_methods/before_type_cast'
    autoload :Dirty,          'recliner/attribute_methods/dirty'
    autoload :Defaults,       'recliner/attribute_methods/defaults'
    autoload :Protected,      'recliner/attribute_methods/protected'
    
    extend ActiveSupport::Concern
    
    include ActiveModel::AttributeMethods
    
    included do
      undef_method :id
    end
    
    module ClassMethods
      # Generates all the attribute related methods for defined properties
      # accessors, mutators and query methods.
      def define_attribute_methods
        super(properties.keys)
      end
      
      def property(*args)
        super
        undefine_attribute_methods
      end
    end
    
    #
    def attributes
      @attributes ||= {}
    end
    
    #
    def attributes=(attrs)
      attrs.each do |key, value|
        self.send("#{key}=", value)
      end
    end
    
    # def clone_attributes(reader_method = :read_attribute, attributes = {})
    #   self.attribute_names.inject(attributes) do |attrs, name|
    #     attrs[name] = clone_attribute_value(reader_method, name)
    #     attrs
    #   end
    # end
    
    def clone_attribute_value(attribute_name)
      value = read_attribute(attribute_name)
      value.duplicable? ? value.clone : value
    rescue TypeError, NoMethodError
      value
    end
    
    def method_missing(method_id, *args, &block)
      # If we haven't generated any methods yet, generate them, then
      # see if we've created the method we're looking for.
      unless self.class.attribute_methods_generated?
        self.class.define_attribute_methods
        method_name = method_id.to_s
        
        #guard_private_attribute_method!(method_name, args)
        
        if self.class.generated_attribute_methods.instance_methods.include?(method_name)
          return self.send(method_id, *args, &block)
        end
      end
      
      super
    end
    
    def respond_to?(*args)
      self.class.define_attribute_methods
      super
    end
    
    def to_couch
      attributes_with_class.to_couch
    end
  
  protected
    def attribute_method?(attr_name)
      properties.include?(attr_name)
    end
    
  private
    def attributes_with_class
      attributes.merge(:class => self.class.name)
    end
  end
end
