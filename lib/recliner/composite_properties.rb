module Recliner
  module CompositeProperties
    extend ActiveSupport::Concern
    
    module ClassMethods
      def Set(type=Object)
        returning Class.new(Set) do |klass|
          klass.type = type
        end
      end
    end
    
    class Set < Array
      class_inheritable_accessor :type
      
      def self.from_couch(array)
        self[*(array || []).map { |item| type.from_couch(item) }]
      end
      
      def self.inspect
        if self == Set
          super
        else
          "#<Set[#{type}]>"
        end
      end
    end
  end
end
