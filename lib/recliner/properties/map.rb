module Recliner
  module Properties
    module Map
      extend ActiveSupport::Concern
      
      included do
        Recliner::Property.send(:include, PropertyWithMapDefault)
      end
      
      module ClassMethods
        def Map(mapping)
          raise ArgumentError, 'Exactly one type mapping must be given' unless mapping.keys.size == 1
          
          mapping = mapping.to_a.first
          
          @map_class_cache ||= {}
          @map_class_cache[mapping] ||= begin
            returning Class.new(Recliner::Map) do |klass|
              klass.from, klass.to = mapping
            end
          end
        end
      end
      
      module PropertyWithMapDefault
        extend ActiveSupport::Concern
        
        included do
          alias_method_chain :default_value, :map
        end
        
        def default_value_with_map(instance)
          result = default_value_without_map(instance)
          
          if type.superclass == Recliner::Map
            if default
              result = type[default]
            else
              result = type.new
            end
          end
          
          result
        end
      end
    end
  end
  
  class Map < Hash
    class_inheritable_accessor :from, :to
    
    class << self
      def from_couch(hash)
        result = new
        hash.each_pair { |key, value| result[from.from_couch(key)] = to.from_couch(value) }
        result
      end
      
      def inspect
        if self == Map
          super
        else
          "#<Map[#{from} -> #{to}]>"
        end
      end
    end
    
    def self.[](hash)
      result = new
      result.update(hash)
      result
    end
    
    def [](key)
      super(convert_key(key))
    end
    
    # Fetches the value for the specified key, same as doing hash[key]
    def fetch(key, *args, &block)
      super(convert_key(key), *args, &block)
    end
    
    # Assigns a new value to the map:
    #
    #   map[:key] = "value"
    #
    def []=(key, value)
      super(convert_key(key), convert_value(value))
    end
    
    def store(key, value)
      super(convert_key(key), convert_value(value))
    end
    
    # Updates the instantized map with values from the second:
    #
    #   map_1 = Map.new
    #   map_1[:key] = "value"
    #
    #   map_2 = Map.new
    #   map_2[:key] = "New Value!"
    #
    #   map_1.update(map_2) # => {"key"=>"New Value!"}
    #
    def update(hash)
      hash.each_pair { |key, value| self[key] = value }
      self
    end
    
    # Checks the map for a key matching the argument passed in:
    #
    #   map["key"] = "value"
    #   map.key? :key  # => true
    #   map.key? "key" # => true
    #
    def key?(key)
      super(convert_key(key))
    end
    
    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?
    
    def replace(hash)
      clear
      update(hash)
    end
    
  private
    def convert_key(key)
      if from == Integer
        key.to_i
      elsif from == String
        key.to_s
      elsif key.kind_of?(from)
        key
      else
        raise TypeError, "expected #{from} but got #{key.class}"
      end
    end
    
    def convert_value(value)
      if to == String
        value.to_s
      elsif value.kind_of?(to)
        value
      else
        raise TypeError, "expected #{to} but got #{value.class}"
      end
    end
  end
end
