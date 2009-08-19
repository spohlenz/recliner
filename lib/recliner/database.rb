module Recliner
  class Database
    attr_reader :uri

    def initialize(uri)
      @uri = uri
#       create_database_if_missing!
    end

    def get(path=nil, params={})
      Recliner.get(uri_for(path), params)
    end

    def post(path, payload, params={})
      Recliner.post(uri_for(path), payload, params)
    end

    def put(path, payload, params={})
      Recliner.put(uri_for(path), payload, params)
    end

    def delete(path)
      Recliner.delete("#{uri}/#{path}") if path
    end

    def delete!
      Recliner.delete(uri)
    end
    
    def create!
      Recliner.put(uri)
    end
    
    def recreate!
      delete! rescue nil
      create!
    end

#     def clear!
#       docs = get("_all_docs")['rows']
#       post("_bulk_docs", {
#         :docs => docs.map { |doc| { '_id' => doc['id'], '_rev' => doc['value']['rev'], '_deleted' => true } }
#       })
#     end

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
