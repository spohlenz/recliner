module Recliner::Document::Properties
  def self.included(base)
    base.extend(ClassMethods)
    
    base.class_inheritable_accessor :properties
    base.properties = {}
  end
  
  module ClassMethods
    def property(name, type, options={})
      as = options[:as] || name
      properties[name.to_sym] = as
      
      class_eval <<-END_RUBY
        def #{name}
          attributes['#{as}']
        end
    
        def #{name}=(value)
          attributes['#{as}'] = value
        end
      END_RUBY
    end
    
    def default_attributes
      properties.inject({}) do |result, pair|
        name, as = pair
        result[as] = nil unless [:id, :rev].include?(name)
        result
      end
    end
  end
  
  def attributes
    @attributes ||= self.class.default_attributes
  end
  
  def attributes=(attrs)
    attrs.each do |key, value|
      as = self.class.properties[key.to_sym]
      attributes[as] = value if as
    end
  end
  
  def attributes_with_class
    attributes.merge(:class => self.class.name)
  end
end
