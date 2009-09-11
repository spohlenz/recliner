module Recliner
  class ViewFunction
    class_inheritable_accessor :definition
    
    def initialize(body)
      if body =~ /^\s*function/
        @body = body
      else
        @body = "#{definition} { #{body} }"
      end
    end
    
    def to_s
      @body
    end
    
    def to_couch
      @body
    end
    
    def ==(other)
      to_s == other.to_s
    end
  end
  
  class ViewFunction::Map < ViewFunction
    self.definition = 'function(doc)'
  end
    
  class ViewFunction::Reduce < ViewFunction
    self.definition = 'function(keys, values, rereduce)'
  end
end
