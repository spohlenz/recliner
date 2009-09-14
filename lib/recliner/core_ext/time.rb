class Time
  # Converts a string representation of a time to a Time object.
  def self.from_couch(val)
    case val
    when String
      parse(val)
    else
      val
    end
  end
  
  # Converts the Time object to a consistent string format (YYYY/MM/DD HH:MM:SS ZONE) for JSON serialization.
  def to_couch
    strftime('%Y/%m/%d %T %z')
  end
end
