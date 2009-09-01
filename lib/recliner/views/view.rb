module Recliner
  class View
    attr_reader :map, :reduce

    def initialize(options={})
  #     if options[:map]
        @map    = Recliner::ViewFunction::Map.new(options[:map])
        @reduce = Recliner::ViewFunction::Reduce.new(options[:reduce]) if options[:reduce]
  #     else
  #       @map, @reduce = Recliner::ViewGenerator.new(options).generate
  #     end
    end

    def to_couch
      returning({}) do |result|
        result[:map] = map
        result[:reduce] = reduce if reduce
      end.to_couch
    end
    
    def self.from_couch(hash)
      new(:map => hash['map'], :reduce => hash['reduce'])
    end

    def ==(other)
      to_couch == other.to_couch
    end
  end
end
