class Boolean < TrueClass
  def self.from_couch(val)
    case val
    when 'true'
      true
    when 'false'
      false
    else
      val
    end
  end
end
