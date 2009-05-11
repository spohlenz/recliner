class Date
  def self.from_couch(val)
    case val
    when String
      parse(val)
    else
      val
    end
  end
end
