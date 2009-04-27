class Date
  def self.from_json(val)
    case val
    when String
      parse(val)
    else
      val
    end
  end
end
