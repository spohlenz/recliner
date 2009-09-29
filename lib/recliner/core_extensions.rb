# Define Boolean type so that property types can be set to Boolean.
Boolean = TrueClass

# Defines default +to_couch+ and +from_couch+ methods.
class Object
  def self.from_couch(val)
    Recliner::Conversions.convert(val, self, :from => :couch)
  end
  
  def to_couch
    Recliner::Conversions.convert(self, :couch)
  end
end
