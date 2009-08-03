class ParentDocument < Recliner::Document; end

class ChildDocument < Recliner::Document
  belongs_to :parent
end
