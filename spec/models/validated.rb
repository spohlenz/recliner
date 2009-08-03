class ValidatedDocument < Recliner::Document
  property :name, String
  validates_presence_of :name
end
