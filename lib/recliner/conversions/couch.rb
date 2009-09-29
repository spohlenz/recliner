# To couch format

Recliner::Conversions.register(Object, :couch) { self }

Recliner::Conversions.register(Date, :couch) { strftime('%Y/%m/%d') }

Recliner::Conversions.register(Time, :couch) { strftime('%Y/%m/%d %T %z') }

Recliner::Conversions.register(Array, :couch) do |array|
  array.map { |item| item.to_couch }
end

Recliner::Conversions.register(Hash, :couch) do |hash|
  hash.inject({}) { |result, (key, value)|
    result[key.to_s] = value.to_couch
    result
  }
end


# From couch format

Recliner::Conversions.register(:couch, Hash) { self }
Recliner::Conversions.register(:couch, Array) { self }
Recliner::Conversions.register(:couch, String) { self }
Recliner::Conversions.register(:couch, Integer) { self }
Recliner::Conversions.register(:couch, Float) { self }

Recliner::Conversions.register(:couch, Boolean) do
  case self
  when true, 'true', '1', 1
    true
  when false, 'false', '0', 0
    false
  else
    nil
  end
end

Recliner::Conversions.register(:couch, Date) do
  Date.parse(self)
end

Recliner::Conversions.register(:couch, Time) do
  Time.parse(self)
end
