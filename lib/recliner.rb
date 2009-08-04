activesupport_path = "#{File.dirname(__FILE__)}/../vendor/activesupport/lib"
$:.unshift(activesupport_path) if File.directory?(activesupport_path)

activemodel_path = "#{File.dirname(__FILE__)}/../vendor/activemodel/lib"
$:.unshift(activemodel_path) if File.directory?(activemodel_path)

require 'json'
require 'rest_client'
require 'uri'

$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'core_ext'

require 'recliner/configuration'
require 'recliner/exceptions'

module Recliner
  VERSION = '0.0.1'
  
  autoload :Database,            'recliner/database'
  autoload :Document,            'recliner/document'
  
  autoload :Properties,          'recliner/properties'
  autoload :CompositeProperties, 'recliner/composite_properties'
  autoload :Views,               'recliner/views'
  autoload :ViewFunctions,       'recliner/view_functions'
  autoload :ViewGenerator,       'recliner/view_generator'
  autoload :Callbacks,           'recliner/callbacks'
  autoload :Validations,         'recliner/validations'
  autoload :Associations,        'recliner/associations'
  autoload :Timestamps,          'recliner/timestamps'
  autoload :PrettyInspect,       'recliner/pretty_inspect'
  
  class << self
    def get(uri, params={})
      JSON.parse(RestClient.get("#{uri}#{to_query_string(params)}"))
    rescue RestClient::ResourceNotFound
      raise DocumentNotFound
    end
    
    def post(uri, payload={}, params={})
      JSON.parse(RestClient.post("#{uri}#{to_query_string(params)}", payload.to_json))
    end
    
    def put(uri, payload={}, params={})
      JSON.parse(RestClient.put("#{uri}#{to_query_string(params)}", payload.to_json))
    rescue RestClient::RequestFailed => e
      rescue_from_failed_request(e)
    end
    
    def delete(uri)
      RestClient.delete(uri)
    rescue RestClient::ResourceNotFound
      raise DocumentNotFound
    rescue RestClient::RequestFailed => e
      rescue_from_failed_request(e)
    end
  
  private
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
