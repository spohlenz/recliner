require 'active_support/core_ext/hash/slice'

module Recliner
  class View
    attr_reader :map, :reduce

    def initialize(options={})
      if options[:map]
        @map    = Recliner::ViewFunction::Map.new(options[:map])
        @reduce = Recliner::ViewFunction::Reduce.new(options[:reduce]) if options[:reduce]
      else
        @map, @reduce = Recliner::ViewGenerator.new(options).generate
      end
    end
    
    def self.from_couch(hash)
      new(:map => hash['map'], :reduce => hash['reduce'])
    end

    def ==(other)
      to_couch == other.to_couch
    end
    
    def invoke(database, path, *args)
      options, couch_options = split_options!(args.extract_options!)
      
      raw = fetch(database, path, args, couch_options)
      
      if options[:raw]
        raw
      else
        instantiate(raw['rows'])
      end
    end
    
  private
    def fetch(database, path, keys, options)
      keys = options.delete(:keys) if options[:keys]
      
      if keys.size > 1
        database.post(path, { :keys => keys }, options)
      else
        options[:key] = keys.first if keys.size == 1
        database.get(path, options)
      end
    end
    
    def instantiate(rows)
      rows.map { |row|
        value = row['value']
        
        if value.is_a?(Hash) && value['class']
          Document.instantiate_from_database(value)
        else
          value
        end
      }
    end
    
    INTERNAL_OPTIONS = [ :raw ]
    
    def split_options!(options)
      [ options, options.slice!(*INTERNAL_OPTIONS) ]
    end
  end
end
