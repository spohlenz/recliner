class Date
  # Converts a string representation of a date to a Date object.
  def self.from_couch(val)
    case val
    when String
      parse(val)
    else
      val
    end
  end
end
