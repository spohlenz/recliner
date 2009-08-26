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
  
  def remove_defined_constants
    if @defined_constants
      @defined_constants.each do |const|
        Object.send(:remove_const, const)
      end
      
      @defined_constants = nil
    end
  end
end

World(ReclinerWorld)

After { remove_defined_constants }
