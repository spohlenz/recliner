Recliner::Conversions.register(Date, String) { |date| date.to_s }
Recliner::Conversions.register(Time, Date) { |time| time.to_date }

Recliner::Conversions.register(String, Date) do |str|
  parts = Date._parse(str)
  Date.new(parts[:year], parts[:mon], parts[:mday]) rescue nil
end

