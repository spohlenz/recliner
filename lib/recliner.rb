activesupport_path = "#{File.dirname(__FILE__)}/../vendor/activesupport/lib"
$:.unshift(activesupport_path) if File.directory?(activesupport_path)

activemodel_path = "#{File.dirname(__FILE__)}/../vendor/activemodel/lib"
$:.unshift(activemodel_path) if File.directory?(activemodel_path)

require 'active_support'
require 'active_model'

require 'json'
require 'restclient'
require 'uri'

require 'recliner/core_ext'
require 'recliner/exceptions'
require 'recliner/configuration'

module Recliner
  VERSION = '0.0.1'
  
  autoload :Document,            'recliner/document'
  autoload :Database,            'recliner/database'
  
  autoload :AttributeMethods,    'recliner/attribute_methods'
  
  autoload :Properties,          'recliner/properties'
  autoload :Property,            'recliner/properties/property'
  autoload :Map,                 'recliner/properties/map'
  autoload :Set,                 'recliner/properties/set'
  
  autoload :Views,               'recliner/views'
  autoload :View,                'recliner/views/view'
  autoload :ViewDocument,        'recliner/views/document'
  autoload :ViewFunction,        'recliner/views/function'
  autoload :ViewGenerator,       'recliner/views/generator'
  
  autoload :Associations,        'recliner/associations'
  
  autoload :Validations,         'recliner/validations'
  autoload :Callbacks,           'recliner/callbacks'
  
  autoload :Timestamps,          'recliner/timestamps'
  autoload :PrettyInspect,       'recliner/pretty_inspect'
  
  class << self
    # Performs a HTTP GET request on a JSON resource, deserializing the response.
    #
    # ==== Parameters
    #
    # * +uri+    - the URI of the resource
    # * +params+ - a hash of parameters to serialize with the URI
    #
    # ==== Example
    #
    #   >> Recliner.get('http://localhost:5984/my-database/some-document', :rev => '12-3220752267')
    #   => { '_id' => 'some-document', '_rev' => '12-3220752267', 'title' => 'Document title' }
    def get(uri, params={})
      request(:get, uri, params)
    end
    
    # Performs a HTTP POST request on a JSON resource, deserializing the response.
    #
    # ==== Parameters
    #
    # * +uri+     - the URI of the resource
    # * +payload+ - a hash of the data to POST
    # * +params+  - a hash of parameters to serialize with the URI
    #
    # ==== Example
    #
    #   >> Recliner.post('http://localhost:5984/my-database', { :title => 'Document title' })
    #   => { 'id' => '12eec4c198ef0e843cd16761fc565208', 'rev' => '1-1503678650', 'ok' => true }
    def post(uri, payload={}, params={})
      request(:post, uri, params, payload)
    end
    
    # Performs a HTTP PUT request on a JSON resource, deserializing the response.
    #
    # ==== Parameters
    #
    # * +uri+    - the URI of the resource
    # * +payload+ - a hash of the data to PUT
    # * +params+  - a hash of parameters to serialize with the URI
    #
    # ==== Example
    #
    #   >> Recliner.put('http://localhost:5984/my-database/some-document', { :title => 'Document title' })
    #   => { 'id' => 'some-document', 'rev' => '2-2152886926', 'ok' => true }
    def put(uri, payload={}, params={})
      request(:put, uri, params, payload)
    end
    
    # Performs a HTTP DELETE request on a JSON resource, deserializing the response.
    #
    # ==== Parameters
    #
    # * +uri+    - the URI of the resource
    # * +params+ - a hash of parameters to serialize with the URI, in particular the revision :rev
    #
    # ==== Example
    #
    #   >> Recliner.delete('http://localhost:5984/my-database/some-document', :rev => '2-2152886926')
    #   => { 'id' => 'some-document', 'rev' => '3-3894620555', 'ok' => true }
    def delete(uri, params={})
      uri << "?rev=#{params.delete(:rev)}" if params[:rev]
      request(:delete, uri, params)
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

I18n.load_path << File.dirname(__FILE__) + '/recliner/locale/en.yml'
