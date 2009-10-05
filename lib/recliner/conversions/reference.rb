Recliner::Conversions.register(Recliner::Associations::Reference, :couch) { |ref| ref.id }
Recliner::Conversions.register(:couch, Recliner::Associations::Reference) { |str| Recliner::Associations::Reference.new(str) }
Recliner::Conversions.register(String, Recliner::Associations::Reference) { |str| Recliner::Associations::Reference.new(str) }
