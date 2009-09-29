require 'time'

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
end
