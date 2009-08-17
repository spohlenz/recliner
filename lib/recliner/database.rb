module Recliner
  class Database
    attr_reader :uri
  
    def initialize(uri)
      @uri = uri
      create_database_if_missing!
    end
  
    def get(id, params={})
      Recliner.get("#{uri}/#{id}", params)
    end
  
    def post(path, payload, params={})
      Recliner.post("#{uri}/#{path}", payload, params)
    end
  
    def put(path, payload, params={})
      Recliner.put("#{uri}/#{path}", payload, params)
    end
  
    def delete(path)
      Recliner.delete("#{uri}/#{path}")
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
    
    def clear!
      docs = get("_all_docs")['rows']
      post("_bulk_docs", {
        :docs => docs.map { |doc| { '_id' => doc['id'], '_rev' => doc['value']['rev'], '_deleted' => true } }
      })
    end

  private
    def create_database_if_missing!
      Recliner.get("#{uri}")
    rescue DocumentNotFound
      create!
    end
  end
end
