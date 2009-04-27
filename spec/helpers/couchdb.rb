module CouchDB
  extend self
  
  # Recreate the document at the given URI
  def document_at(uri, hash)
    RestClient.put(uri, hash.to_json)
  rescue
    result = JSON.parse(RestClient.get(uri))
    RestClient.delete("#{uri}?rev=#{result['_rev']}")
    RestClient.put(uri, hash.to_json)
  end

  # Ensure no document exists at the given URI
  def no_document_at(uri)
    result = JSON.parse(RestClient.get(uri))
    RestClient.delete("#{uri}?rev=#{result['_rev']}")
  rescue
  end

  # Get the revision of the document at the given URI
  def revision_for_document(uri)
    result = JSON.parse(RestClient.get(uri))
    result['_rev']
  end  
end
