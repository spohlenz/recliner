module Recliner
  module Properties
    module Set#:nodoc:
      extend ActiveSupport::Concern
      
      included do
        Recliner::Property.send(:include, PropertyWithSetDefault)
      end
      
      module ClassMethods
        # Creates a new Set class with the given type.
        # A Set operates like an Array, but has strict type enforcement. It also automatically
        # converts its elements to the correct type when loading from couch format.
        #
        # Set classes are cached so that:
        #   Set(String).object_id == Set(String).object_id
        #
        # ==== Example
        #
        #    >> Set(String)  # creates a set which can contain String elements
        #    >> Set(Address) # creates a set which can contain Address elements
        #                    # (Address must be serializable to/from couch format)
        def Set(type)
          @set_class_cache ||= {}
          @set_class_cache[type] ||= begin
            returning Class.new(Recliner::Set) do |klass|
              klass.type = type
            end
          end
        end
      end
      
      module PropertyWithSetDefault#:nodoc:
        extend ActiveSupport::Concern
        
        included do
          alias_method_chain :default_value, :set
        end
        
        def default_value_with_set(instance)
          result = default_value_without_set(instance)
          
          if type.superclass == Recliner::Set
            if default
              result = type[*default]
            else
              result = type.new
            end
          end
          
          result
        end
      end
    end
  end
  
  class Set < Array
    class_inheritable_accessor :type
    
    class << self
      def from_couch(array)
        self[*array.map { |i| type.from_couch(i) }]
      end
      
      def inspect
        if self == Set
          super
        else
          "#<Set[#{type}]>"
        end
      end
      
      def [](*values)
        super(*values.map { |i| convert_value(i) })
      end
    end
    
    def []=(index, value)
      super(index, convert_value(value))
    end
    
    def +(other_array)
      self.class[*super(other_array.map { |i| convert_value(i) })]
    end
    
    def <<(obj)
      super(convert_value(obj))
    end
    
    def concat(other_array)
      super(other_array.map { |i| convert_value(i) })
    end
    
    def delete(obj)
      super(convert_value(obj))
    end
    
    def index(obj)
      super(convert_value(obj))
    end
    
    def insert(index, obj)
      super(index, convert_value(obj))
    end
    
    def push(*values)
      super(*values.map { |i| convert_value(i) })
    end
    
    def rindex(obj)
      super(convert_value(obj))
    end
    
    def unshift(*values)
      super(*values.map { |i| convert_value(i) })
    end
  
  private
    def convert_value(value)
      self.class.convert_value(value)
    end
    
    def self.convert_value(value)
      Conversions.convert(value, type)
    end
  end
end
