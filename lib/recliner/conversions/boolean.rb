Recliner::Conversions.register(TrueClass, Boolean) { true }
Recliner::Conversions.register(FalseClass, Boolean) { false }

Recliner::Conversions.register(String, Boolean) do |str|
  case str.downcase
  when '1', 't', 'y', 'true', 'yes'
    true
  when '0', 'f', 'n', 'false', 'no'
    false
  else
    nil
  end
end

Recliner::Conversions.register(Fixnum, Boolean) do |num|
  num > 0
end
