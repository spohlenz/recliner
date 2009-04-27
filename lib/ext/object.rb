class Object
  def to_json
    self
  end
  
  def self.from_json(val)
    val
  end
end
