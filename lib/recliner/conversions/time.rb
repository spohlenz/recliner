Recliner::Conversions.register(Time, String) { |time| strftime('%Y-%m-%d %T %z') }
Recliner::Conversions.register(Date, Time) { |date| date.to_time }

Recliner::Conversions.register(String, Time) do |str|
  parts = Date._parse(str)
  Time.time_with_datetime_fallback(:local, parts[:year], parts[:mon], parts[:mday], parts[:hour], parts[:min], parts[:sec]) rescue nil
end
