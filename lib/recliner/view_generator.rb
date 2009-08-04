module Recliner
  class ViewGenerator
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def generate
      map = ""
      
      map << "if (#{conditions}) {"
      map << "  emit(#{key}, doc);"
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
    
    def conditions
      options[:conditions!].map { |key, value|
        "doc.#{key} === #{value.to_json}"
      }.join(' && ')
    end
  end
end
