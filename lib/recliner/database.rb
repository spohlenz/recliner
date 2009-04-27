class Recliner::Database
  attr_reader :uri
  
  def initialize(uri)
    @uri = uri
    create_database_if_missing!
  end
  
  def get(id)
    Recliner.get("#{uri}/#{id}")
  end
  
  def post(payload)
    Recliner.post(uri, payload)
  end
  
  def put(id, payload)
    Recliner.put("#{uri}/#{id}", payload)
  end
  
  def delete(id)
    Recliner.delete("#{uri}/#{id}")
  end
  
  def delete!
    Recliner.delete(uri)
  end
  
  def create!
    Recliner.put(uri)
  end

private
  def create_database_if_missing!
    create! rescue nil
  end
end
