activesupport_path = "#{File.dirname(__FILE__)}/../vendor/activesupport/lib"
$:.unshift(activesupport_path) if File.directory?(activesupport_path)

activemodel_path = "#{File.dirname(__FILE__)}/../vendor/activemodel/lib"
$:.unshift(activemodel_path) if File.directory?(activemodel_path)

require 'active_support/all'

require 'json'
require 'restclient'
# require 'uri'
# 
$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'core_ext'

# require 'recliner/configuration'
require 'recliner/exceptions'

module Recliner
  VERSION = '0.0.1'
  
  autoload :Document,            'recliner/document'
  autoload :Database,            'recliner/database'
  
  autoload :AttributeMethods,    'recliner/attribute_methods'
  autoload :Properties,          'recliner/properties'
  # autoload :CompositeProperties, 'recliner/composite_properties'
  # autoload :Views,               'recliner/views'
  # autoload :ViewFunctions,       'recliner/view_functions'
  # autoload :ViewGenerator,       'recliner/view_generator'
  # autoload :Callbacks,           'recliner/callbacks'
  # autoload :Validations,         'recliner/validations'
  # autoload :Associations,        'recliner/associations'
  # autoload :Timestamps,          'recliner/timestamps'
  # autoload :PrettyInspect,       'recliner/pretty_inspect'
  
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
      raise DocumentNotFound
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
