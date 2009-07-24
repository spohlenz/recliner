class Array
  def to_couch
    map { |e| e.to_couch }
  end
end
