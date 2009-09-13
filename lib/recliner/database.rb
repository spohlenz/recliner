module Recliner
  class Database
    attr_reader :uri
    
    # Creates a new database object with the given URI.
    #
    # ==== Example
    #
    #   >> database = Recliner::Database.new('http://localhost:5984/my-database')
    def initialize(uri)
      @uri = uri
#       create_database_if_missing!
    end
    
    # Performs a HTTP GET request on a JSON resource from this database, deserializing the response.
    #
    # ==== Parameters
    #
    # * +path+   - the path of the resource
    # * +params+ - a hash of parameters to serialize with the URI
    #
    # ==== Example
    #
    #   >> database.get('some-document', :rev => '12-3220752267')
    #   => { '_id' => 'some-document', '_rev' => '12-3220752267', 'title' => 'Document title' }
    def get(path=nil, params={})
      Recliner.get(uri_for(path), params)
    end
    
    # Performs a HTTP POST request on a JSON resource from this database, deserializing the response.
    #
    # ==== Parameters
    #
    # * +path+    - the path of the resource
    # * +payload+ - a hash of the data to POST
    # * +params+  - a hash of parameters to serialize with the URI
    #
    # ==== Example
    #
    #   >> database.post('my-database', { :title => 'Document title' })
    #   => { 'id' => '12eec4c198ef0e843cd16761fc565208', 'rev' => '1-1503678650', 'ok' => true }
    def post(path, payload, params={})
      Recliner.post(uri_for(path), payload, params)
    end
    
    # Performs a HTTP PUT request on a JSON resource from this database, deserializing the response.
    #
    # ==== Parameters
    #
    # * +path+    - the path of the resource
    # * +payload+ - a hash of the data to PUT
    # * +params+  - a hash of parameters to serialize with the URI
    #
    # ==== Example
    #
    #   >> database.put('some-document', { :title => 'Document title' })
    #   => { 'id' => 'some-document', 'rev' => '2-2152886926', 'ok' => true }
    def put(path, payload, params={})
      Recliner.put(uri_for(path), payload, params)
    end
    
    # Performs a HTTP DELETE request on a JSON resource from this database, deserializing the response.
    #
    # ==== Parameters
    #
    # * +path+   - the path of the resource
    # * +params+ - a hash of parameters to serialize with the URI, in particular the revision :rev
    #
    # ==== Example
    #
    #   >> database.delete('some-document', :rev => '2-2152886926')
    #   => { 'id' => 'some-document', 'rev' => '3-3894620555', 'ok' => true }
    def delete(path, params={})
      Recliner.delete("#{uri}/#{path}", params) if path
    end
    
    # Deletes the database by performing a HTTP DELETE request on the database URI.
    def delete!
      Recliner.delete(uri)
    end
    
    # Creates the database by performing a HTTP PUT request on the database URI.
    def create!
      Recliner.put(uri)
    end
    
    # Recreates the database by issuing a HTTP DELETE request followed by a HTTP PUT request to the database URI.
    def recreate!
      delete! rescue nil
      create!
    end
    
    # Clears all documents from the database using the CouchDB bulk document API.
    def clear!
      docs = get("_all_docs")['rows']
      post("_bulk_docs", {
        :docs => docs.map { |doc| { '_id' => doc['id'], '_rev' => doc['value']['rev'], '_deleted' => true } }
      }) unless docs.empty?
    end
    
    # Compares databases for equality. Two databases are considered equal if they have the same URI.
    def ==(other)
      other.is_a?(Recliner::Database) && uri == other.uri
    end

  private
    def uri_for(path)
      [uri, path].compact.join('/')
    end
    
#     def create_database_if_missing!
#       Recliner.get(uri)
#     rescue DocumentNotFound
#       create!
#     end
  end
end
