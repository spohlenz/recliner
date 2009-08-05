module CouchDB
  class << self
    @@prefix = 'http://localhost:5984/recliner-test'
    
    # GET a document at the given URI
    def get(uri)
      JSON.parse(RestClient.get(normalize(uri)))
    end
    
    # Recreate the document at the given URI
    def document_at(uri, hash)
      RestClient.put(normalize(uri), hash.to_json)
    rescue
      result = JSON.parse(RestClient.get(normalize(uri)))
      RestClient.delete("#{normalize(uri)}?rev=#{result['_rev']}")
      RestClient.put(normalize(uri), hash.to_json)
    end

    # Ensure no document exists at the given URI
    def no_document_at(uri)
      result = JSON.parse(RestClient.get(normalize(uri)))
      RestClient.delete("#{normalize(uri)}?rev=#{result['_rev']}")
    rescue
    end

    # Get the revision of the document at the given URI
    def revision_for_document(uri)
      result = JSON.parse(RestClient.get(normalize(uri)))
      result['_rev']
    end
    
    # Ensures a database exists at the given URI
    def database_at(uri)
      RestClient.put(normalize(uri))
    rescue
      no_database_at(normalize(uri))
      database_at(normalize(uri))
    end
    
    def no_database_at(uri)
      RestClient.delete(normalize(uri)) rescue nil
    end
  
  private
    def normalize(uri)
      uri =~ /^http/ ? uri : "#{@@prefix}/#{uri}"
    end
  end
end
