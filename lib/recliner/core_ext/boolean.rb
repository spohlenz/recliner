class Boolean < TrueClass
  # Converts string or integer representations of a boolean
  # value to an actual boolean.
  def self.from_couch(val)
    case val
    when 'true', '1', 1
      true
    when 'false', '0', 0, nil
      false
    else
      val
    end
  end
end
