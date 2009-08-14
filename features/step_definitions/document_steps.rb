Given /^a document exists at "([^\"]*)"$/ do |uri|
  RestClient.put(uri, '{}')
end

Given /^no document exists at "([^\"]*)"$/ do |uri|
  begin
    RestClient.delete(uri)
  rescue RestClient::ResourceNotFound
    # The document is already missing
  end
end

Given /^I know the revision of the document at "([^\"]*)"$/ do |uri|
  @revision = JSON.parse(RestClient.get(uri))['_rev']
end

Given /^the document at "([^\"]*)" has (\d+) previous revisions?$/ do |uri, count|
  count.to_i.times do
    revision = JSON.parse(RestClient.get(uri))['_rev']
    RestClient.put(uri, { '_rev' => revision }.to_json)
  end
end

Then /^there should be no document at "([^\"]*)"$/ do |uri|
  When "I GET \"#{uri}\""
  Then "a \"Recliner::DocumentNotFound\" exception should be raised"
end
