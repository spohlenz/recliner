class Hash
  def to_couch
    inject({}) do |result, (key, value)|
      result[key.to_s] = value.to_couch
      result
    end
  end
end
