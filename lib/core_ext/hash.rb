class Hash
  def to_couch
    inject({}) do |result, (key, value)|
      result[key.to_couch] = value.to_couch
      result
    end
  end
end
