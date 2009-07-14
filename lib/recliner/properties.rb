require 'uuid'
require 'active_support/core_ext/hash/indifferent_access'

module Recliner
  class Property < Struct.new(:name, :type, :as, :default)
    def default_value(instance)
      default.respond_to?(:call) ? default.call(instance) : default
    end
  end
  
  module Properties
    def self.included(base)
      base.extend(ClassMethods)
    
      base.class_inheritable_accessor :properties
      base.properties = {}
    end
    
    module ClassMethods
      #
      #
      #
      def property(name, *args, &block)
        options = args.extract_options!
        type = args.first
        
        if type
          prop = Property.new(name.to_s, type, (options[:as] || name).to_s, options[:default])
          properties[name.to_sym] = prop
          
          create_property_accessors!(prop)
        elsif block_given?
          
        else
          raise 'Either a type or block must be provided'
        end
      end
      
      #
      #
      #
      def model_properties
        properties.reject { |name, property| [:id, :rev].include?(name) }
      end
      
      #
      #
      #
      def default_attributes(instance)
        properties.inject({}) do |result, pair|
          name, property = pair
          result[name] = property.default_value(instance) unless name == :rev
          result
        end.with_indifferent_access
      end
    
    private
      def create_property_accessors!(property)
        class_eval <<-END_RUBY
          def #{property.name}                          # def title
            read_attribute(:#{property.name})           #   read_attribute(:title)
          end                                           # end
  
          def #{property.name}=(value)                  # def title(value)
            write_attribute(:#{property.name}, value)   #   write_attribute(:title, value)
          end                                           # end
        END_RUBY
      end
      
    protected
      # Unique ID generation for new documents
      def generate_guid
        UUID.generate
      end
    end
  
    #
    def attributes
      @attributes ||= {}.with_indifferent_access
    end
    
    #
    def attributes=(attrs)
      attrs.each do |key, value|
        self.send("#{key}=", value) unless key == 'class'
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
    
    #
    def read_attribute(name)
      attributes[property(name).as] if property(name)
    end
    
    #
    def write_attribute(name, value)
      attributes[property(name).as] = value if property(name)
      value
    end
    
  private
    def property(name)
      properties[name.to_sym]
    end
  
    def attributes_with_class
      attributes.merge(:class => self.class.name)
    end
  end
end
