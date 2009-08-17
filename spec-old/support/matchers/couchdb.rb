module CouchDB
  module Matchers
    class HaveDocumentMatcher
      def initialize(expected)
        @expected = expected
      end
    
      def matches?(owner)
        raise "Must be called on CouchDB" unless owner == CouchDB
        raise "URI must be supplied via at()" unless @uri
        
        @actual = JSON.parse(RestClient.get(@uri))
        
        if @expected
          @expected.all? do |key, value|
            @actual[key.to_s] == value
          end
        else
          true
        end
      rescue RestClient::ResourceNotFound
        false
      end
    
      def description
        "have document #{@uri}"
      end
    
      def at(uri)
        @uri = uri =~ /^http/ ? uri : "http://localhost:5984/recliner-test/#{uri}"
        self
      end
      
      def failure_message_for_should
        message =  "expected CouchDB database to contain document #{@expected.inspect}\n"
        message += "at #{@uri}\n"
        if @actual
          message += "but instead contained #{@actual.inspect}\n"
        else
          message += "but no document was found"
        end
        message
      end
      
      def failure_message_for_should_not
        "expected CouchDB database to not contain a document at #{@uri}\n"
      end
    end
    
    class HaveDatabaseMatcher
      def initialize(uri)
        @uri = uri
      end
    
      def matches?(owner)
        raise "Must be called on CouchDB" unless owner == CouchDB
        raise "URI must be supplied via at()" unless @uri
        
        RestClient.get(@uri)
        true
      rescue RestClient::ResourceNotFound
        false
      end
    
      def description
        "have database at #{@uri}"
      end
      
      def failure_message_for_should
        "expected CouchDB to have database at #{@uri} but no database was found\n"
      end
      
      def failure_message_for_should_not
        "expected CouchDB not to have database at #{@uri}\n"
      end
    end
    
    def have_document(doc=nil)
      HaveDocumentMatcher.new(doc)
    end
    
    def have_database(uri)
      HaveDatabaseMatcher.new(uri)
    end
  end
end

include CouchDB::Matchers
