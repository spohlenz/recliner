# Defines default +to_couch+ and +from_couch+ methods.
class Object
  def self.from_couch(val)
    val
  end
  
  def to_couch
    self
  end
end
