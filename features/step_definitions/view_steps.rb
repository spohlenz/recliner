Given /^a map view named "([^\"]*)" exists at "([^\"]*)":$/ do |name, uri, function|
  RestClient.put(uri, { :views => { name => { :map => function } } }.to_json)
end
