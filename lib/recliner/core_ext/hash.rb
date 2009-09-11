class Hash
  # Converts the Hash to a JSON-compatible format by converting
  # keys to strings and calling +to_couch+ on each of its values.
  def to_couch
    inject({}) do |result, (key, value)|
      result[key.to_s] = value.to_couch
      result
    end
  end
end
