module Recliner
  # Encapsulates a critical error from CouchDB.
  # Raised by the Recliner base methods when an error response is returned. Use
  # the +error+ and +reason+ methods to retrieve the specific error.
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
  
  class DocumentNotSaved < StandardError; end
  
  class StaleRevisionError < DocumentNotSaved; end

#   class AssociationTypeMismatch < StandardError; end
end
