Recliner::Conversions.register(Recliner::View, :couch) do
  returning({}) do |result|
    result[:map] = map
    result[:reduce] = reduce if reduce
  end.to_couch
end

Recliner::Conversions.register(Recliner::ViewFunction, :couch) { |func| func.to_s }
