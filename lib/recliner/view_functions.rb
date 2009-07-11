module Recliner
  class ViewFunction
    class_inheritable_accessor :definition
  
    def initialize(body)
      if body =~ /^\s*function/
        @body = body
      else
        @body = "#{self.class.definition} { #{body} }"
      end
    end
  
    def to_s
      @body
    end
    
    def to_json
      "\"#{to_s.gsub(/"/, '\"')}\""
    end
    
    def self.create(definition)
      returning Class.new(self) do |klass|
        klass.definition = definition
      end
    end
  end

  MapViewFunction = ViewFunction.create('function(doc)')
  ReduceViewFunction = ViewFunction.create('function(keys, values, rereduce)')
end
