require 'active_support'
require 'json'
require 'rest_client'

$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'core_ext'

module Recliner
  VERSION = '0.0.1'
  
  autoload :Database,      'recliner/database'
  autoload :Document,      'recliner/document'
  
  autoload :Properties,    'recliner/properties'
  autoload :Views,         'recliner/views'
  autoload :PrettyInspect, 'recliner/pretty_inspect'
  
  class DocumentNotFound < StandardError; end
  class DocumentNotSaved < StandardError; end
  class StaleRevisionError < StandardError; end
  
  class << self
    def get(uri)
      JSON.parse(RestClient.get(uri))
    rescue RestClient::ResourceNotFound
      raise DocumentNotFound
    end
    
    def post(uri, payload={})
      JSON.parse(RestClient.post(uri, payload.to_json))
    end
    
    def put(uri, payload={})
      JSON.parse(RestClient.put(uri, payload.to_json))
    rescue RestClient::RequestFailed
      raise StaleRevisionError
    end
    
    def delete(uri)
      RestClient.delete(uri)
    rescue RestClient::ResourceNotFound
      raise DocumentNotFound
    rescue RestClient::RequestFailed
      raise StaleRevisionError
    end
  end
  
  Document.use_database! 'http://localhost:5984/recliner-default'
end
