module Recliner
  class CouchDBError < StandardError
    def initialize(response=nil)
      @error = JSON.parse(response) if response
    end
    
    def error
      @error['error'] if @error
    end
    
    def reason
      @error['reason'] if @error
    end
    
    def message
      "CouchDB error: #{error} (#{reason})"
    end
    
    def to_s
      message
    end
  end
 
  class DocumentNotFound < StandardError; end
  
  class StaleRevisionError < StandardError; end

#   class AssociationTypeMismatch < StandardError; end
end
