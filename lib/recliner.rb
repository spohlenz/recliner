activesupport_path = "#{File.dirname(__FILE__)}/../vendor/activesupport/lib"
$:.unshift(activesupport_path) if File.directory?(activesupport_path)

activemodel_path = "#{File.dirname(__FILE__)}/../vendor/activemodel/lib"
$:.unshift(activemodel_path) if File.directory?(activemodel_path)

require 'active_support/all'

require 'json'
require 'restclient'
# require 'uri'

require 'recliner/core_ext'
require 'recliner/exceptions'
# require 'recliner/configuration'

module Recliner
  VERSION = '0.0.1'
  
  autoload :Document,            'recliner/document'
  autoload :Database,            'recliner/database'
  
  autoload :AttributeMethods,    'recliner/attribute_methods'
  
  autoload :Properties,          'recliner/properties'
  autoload :Property,            'recliner/properties/property'
  autoload :Map,                 'recliner/properties/map'
  # autoload :CompositeProperties, 'recliner/composite_properties'
  
  autoload :Views,               'recliner/views'
  autoload :View,                'recliner/views/view'
  autoload :ViewDocument,        'recliner/views/document'
  autoload :ViewFunction,        'recliner/views/function'
  autoload :ViewGenerator,       'recliner/views/generator'
  
  # autoload :Associations,        'recliner/associations'
  
  autoload :Validations,         'recliner/validations'
  autoload :Callbacks,           'recliner/callbacks'
  
  autoload :Timestamps,          'recliner/timestamps'
  autoload :PrettyInspect,       'recliner/pretty_inspect'
  
  class << self
    def get(uri, params={})
      request(:get, uri, params)
    end
    
    def post(uri, payload={}, params={})
      request(:post, uri, params, payload)
    end
    
    def put(uri, payload={}, params={})
      request(:put, uri, params, payload)
    end
    
    def delete(uri)
      request(:delete, uri)
    end
  
  private
    def request(type, uri, params={}, payload=nil)
      args = [type, "#{uri}#{to_query_string(params)}"]
      args << payload.to_json if payload
      
      JSON.parse(RestClient.send(*args))
    rescue RestClient::ResourceNotFound
      raise DocumentNotFound, "Could not find document at #{uri}"
    rescue RestClient::RequestFailed => e
      rescue_from_failed_request(e)
    end
  
    def rescue_from_failed_request(e)
      case e.http_code
      when 409
        raise StaleRevisionError
      else
        raise CouchDBError, e.http_body
      end
    end
  
    def to_query_string(params)
      str = params.map { |k, v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_json)}" }.join('&')
      str.blank? ? '' : "?#{str}"
    end
  end
end

# I18n.load_path << File.dirname(__FILE__) + '/recliner/locale/en.yml'
