Given /^the database "([^\"]*)" exists$/ do |uri|
  RestClient.delete(uri) rescue nil
  RestClient.put(uri, '')
end

Given /^the default Recliner::Document database is set to "([^\"]*)"$/ do |uri|
  Recliner::Document.database_uri = uri
end
