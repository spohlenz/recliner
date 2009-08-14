Given /^the database "([^\"]*)" exists$/ do |uri|
  RestClient.delete(uri) rescue nil
  RestClient.put(uri, '')
end
