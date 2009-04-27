class Recliner::Document
  Property = Struct.new(:name, :type, :as, :default)
  
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
      def default_attributes
        properties.inject({}) do |result, pair|
          name, property = pair
          result[property.as] = property.default unless [:id, :rev].include?(name)
          result
        end
      end
    
    private
      def create_property_accessors!(property)
        class_eval <<-END_RUBY
          def #{property.name}
            attributes['#{property.as}']
          end
  
          def #{property.name}=(value)
            attributes['#{property.as}'] = #{property.type}.from_json(value)
          end
        END_RUBY
      end
    end
  
    def attributes
      @attributes ||= self.class.default_attributes
    end
  
    def attributes=(attrs)
      attrs.each do |key, value|
        self.send("#{key}=", value) unless key == 'class'
      end
    end
  
    def attributes_with_class
      attributes.merge(:class => self.class.name)
    end
  end
end
