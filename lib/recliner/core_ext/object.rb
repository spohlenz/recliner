# Defines default +to_couch+ and +from_couch+ methods.
class Object
  def self.from_couch(val)
    val
    # Recliner::Conversions.convert(val, self.class, :from => :couch)
  end
  
  def to_couch
    Recliner::Conversions.convert(self, :couch)
  end
end
