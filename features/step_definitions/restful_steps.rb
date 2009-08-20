When /^I GET "([^\"]*)"$/ do |uri|
  @result = record_exception { Recliner.get(uri) }
end

When /^I GET "([^\"]*)" with:$/ do |uri, params|
  params = eval_hash_keys(params.rows_hash)
  @result = record_exception { Recliner.get(uri, params) }
end

When /^I PUT to "([^\"]*)"$/ do |uri|
  @result = record_exception { Recliner.put(uri, {}) }
end

When /^I PUT to "([^\"]*)" with the revision$/ do |uri|
  @result = record_exception { Recliner.put(uri, { '_rev' => @revision }) }
end

When /^I POST to "([^\"]*)"$/ do |uri|
  @result = record_exception { Recliner.post(uri, {}) }
end

When /^I POST to "([^\"]*)" with:$/ do |uri, payload|
  @result = record_exception { Recliner.post(uri, eval(payload)) }
end

When /^I DELETE "([^\"]*)" with the revision$/ do |uri|
  @result = record_exception { Recliner.delete("#{uri}?rev=#{@revision}") }
end

When /^I DELETE "([^\"]*)"$/ do |uri|
  @result = record_exception { Recliner.delete(uri) }
end

Then /^the result should have key "([^\"]*)"$/ do |key|
  @exception.should be_nil
  @result.should have_key(key)
end

Then /^the result should have "([^\"]*)" => "([^\"]*)"$/ do |key, value|
  @exception.should be_nil
  @result[key].to_s.should == value
end

Then /^the result should have "([^\"]*)" matching "([^\"]*)"$/ do |key, regexp|
  @exception.should be_nil
  @result[key].should match(regexp)
end

Then /^a "([^\"]*)" exception should be raised$/ do |exception_class|
  @exception.should_not be_nil
  @exception.class.to_s.should == exception_class
end

Then /^no exception should be raised$/ do
  @exception.should be_nil
end
