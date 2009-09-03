class Time
  def self.from_couch(val)
    case val
    when String
      parse(val)
    else
      val
    end
  end
  
  def to_couch
    strftime('%Y/%m/%d %T %z')
  end
end
