class Array
  # Converts the Array to a JSON-compatible format by calling
  # +to_couch+ on each of its elements.
  def to_couch
    map { |e| e.to_couch }
  end
end
