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

  # Converts the Date object to a consistent string format (YYYY/MM/DD) for JSON serialization.
  def to_couch
    strftime('%Y/%m/%d')
  end
end
