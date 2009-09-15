module Recliner
  module Associations
    class Reference
      attr_reader :id
      
      def initialize(id=nil)
        @id = id
      end
      
      def ==(other)
        other.is_a?(Reference) && id == other.id
      end

      def self.from_couch(id)
        new(id)
      end
      
      def self.parse(id)
        new(id)
      end
      
      def to_couch
        id
      end
      
      def inspect
        id.nil? ? 'nil' : id
      end
      
      def replace(object)
        @id = object.id
        @target = object
      end
      
      def target
        @target ||= Recliner::Document.load!(id) if id
      end
    end
  end
end
