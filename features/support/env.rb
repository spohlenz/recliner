require 'recliner'
require 'restclient'

module ReclinerWorld
  def record_result_and_exception
    begin
      @result = yield
      @exception = nil
    rescue => e
      @result = nil
      @exception = e
    end
  end
  
  def eval_hash_keys(hash)
    h = hash.dup
    h.each { |k, v| h[k] = eval(v) rescue v }
  end
end

World(ReclinerWorld)
