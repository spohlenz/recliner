Recliner::Conversions.register(Numeric, String) { |num| num.to_s }

Recliner::Conversions.register(String, Integer) do |str|
  result = str.to_i

  # string.to_i returns 0 if the string does not contain a number - we want nil
  result = nil if result == 0 && str !~ /^\s*\d/

  result
end

Recliner::Conversions.register(String, Float) do |str|
  result = str.to_f

  # string.to_f returns 0 if the string does not contain a number - we want nil
  result = nil if result == 0.0 && str !~ /^\s*[\d\.]/

  result
end

Recliner::Conversions.register(Numeric, Integer) { |float| float.to_i }
Recliner::Conversions.register(Numeric, Float) { |float| float.to_f }
