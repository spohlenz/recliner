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

      def to_s
        id.to_s
      end
      
      def blank?
        id.blank?
      end
      
      def inspect
        id.nil? ? 'nil' : id
      end
      
      def replace(object)
        @id = object.id
        @target = object
      end
      
      def reload
        @target = nil
      end
      
      def target
        @target ||= Recliner::Document.load!(id) if id
      end
    end
  end
end
