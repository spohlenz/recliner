$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../../lib")

require 'recliner'
require 'restclient'

module ReclinerWorld
  def record_exception
    begin
      result = yield
      @exception = nil
      result
    rescue => e
      @exception = e
      nil
    end
  end
  
  def eval_hash_keys(hash)
    h = hash.dup
    h.each { |k, v| h[k] = eval(v) rescue v }
  end
end

World(ReclinerWorld)
