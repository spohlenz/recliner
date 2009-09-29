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
  
  Conversions.register(Associations::Reference, :couch) { |ref| ref.id }
  Conversions.register(String, Associations::Reference) { |str| Associations::Reference.new(str) }
end
