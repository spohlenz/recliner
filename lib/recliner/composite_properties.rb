module Recliner
  module CompositeProperties
    class Map < Hash
      class_inheritable_accessor :from, :to
      
      def self.from_couch(hash)
        self[*hash.map { |key, value| [ from.from_couch(key), to.from_couch(value) ] }.flatten]
      end
      
      def self.inspect
        if self == Map
          super
        else
          "#<Map[#{from} -> #{to}]>"
        end
      end
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def Map(mapping)
        raise 'Exactly one type mapping must be given' unless mapping.keys.size == 1
        
        returning Class.new(Map) do |klass|
          klass.from, klass.to = mapping.to_a.first
        end
      end

      #def Set(type)
      #end
    end
  end
end
