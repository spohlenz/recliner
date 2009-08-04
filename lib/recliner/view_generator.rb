module Recliner
  class ViewGenerator
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def generate
      map = ""
      
      map << "if (#{conditions}) {"
      map << "  emit(#{key}, #{value});"
      map << "}"
      
      [Recliner::MapViewFunction.new(map), nil]
    end
  
  private
    def key
      key = options[:key] || options[:order]
      
      if key.is_a?(Array)
        '[' + key.map { |k| "doc.#{k}" }.join(', ') + ']'
      else
        "doc.#{key}"
      end
    end
    
    def value
      if options[:select]
        "{" + Array(options[:select]).map { |field|
          "\"#{field}\": doc.#{field}"
        }.join(",") + "}"
      else
        'doc'
      end
    end
    
    def conditions
      conditions = options[:conditions!].map { |k, v| "doc.#{k} === #{v.to_json}" }
      
      case options[:conditions]
      when Hash
        conditions += options[:conditions].map { |k, v| "doc.#{k} === #{v.to_json}" }
      when String
        conditions << "(#{options[:conditions]})"
      end
      
      conditions.join(' && ')
    end
  end
end
