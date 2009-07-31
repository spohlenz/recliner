require 'uuid'
require 'active_support/core_ext/hash/indifferent_access'

module Recliner
  class Property < Struct.new(:name, :type, :as, :default)
    def default_value(instance)
      default.respond_to?(:call) ? default.call(instance) : default
    end
  end
  
  module Properties
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :properties
      self.properties = {}
      
      attr_protected :class
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
          raise 'Not yet supported'
        else
          raise 'Either a type or block must be provided'
        end
        
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
        create_property_reader!(property.name) unless instance_methods.include?(property.name)
        create_property_writer!(property.name) unless instance_methods.include?("#{property.name}=")
        create_property_query!(property.name) unless instance_methods.include?("#{property.name}?")
      end
      
      def create_property_reader!(name)
        class_eval <<-END_RUBY
          def #{name}                          # def title
            read_attribute(:#{name})           #   read_attribute(:title)
          end                                  # end
        END_RUBY
      end
      
      def create_property_writer!(name)
        class_eval <<-END_RUBY
          def #{name}=(value)                  # def title(value)
            write_attribute(:#{name}, value)   #   write_attribute(:title, value)
          end                                  # end
        END_RUBY
      end
      
      def create_property_query!(name)
        class_eval <<-END_RUBY
          def #{name}?                         # def title?
            !#{name}.blank?                    #   !title.blank?
          end                                  # end
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
      remove_protected_attributes(attrs).each do |key, value|
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
    
    #
    def read_attribute(name)
      attributes[property(name).as] if property(name)
    end
    
    #
    def write_attribute(name, value)
      attributes[property(name).as] = value if property(name)
      value
    end
    
    def to_couch
      attributes_with_class.to_couch
    end
    
  private
    def property(name)
      properties[name.to_sym]
    end
  
    def attributes_with_class
      attributes.merge(:class => self.class.name)
    end
    
    def remove_protected_attributes(attrs)
      attrs.reject { |key, value| self.class.protected_attributes.include?(key.to_s) }
    end
  end
end
