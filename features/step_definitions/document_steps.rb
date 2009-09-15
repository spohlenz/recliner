Given /^a document exists at "([^\"]*)"$/ do |uri|
  RestClient.put(uri, '{}')
end

Given /^no document exists at "([^\"]*)"$/ do |uri|
  begin
    result = JSON.parse(RestClient.get(uri))
    RestClient.delete("#{uri}?rev=#{result['_rev']}")
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

Given /^the following document definitions?:$/ do |code|
  @defined_constants ||= []
  @defined_constants += ActiveSupport::Dependencies.new_constants_in(Object) { eval(code) }
end

Given /^I have an unsaved instance of "([^\"]*)"$/ do |klass|
  @instance = klass.constantize.new
end

Given /^I have a saved instance of "([^\"]*)" with id "([^\"]*)"$/ do |klass, id|
  Given "no document exists at \"#{klass.constantize.database.uri}/#{id}\""
  
  @instance = klass.constantize.new(:id => id)
  @instance.save!
  @instance.should_not be_a_new_record
end

Given /^I have a saved instance of "([^\"]*)" with:$/ do |klass, table|
  attributes = table.rows_hash
  @instance = klass.constantize.new(attributes)
  @instance.save!
  @instance.should_not be_a_new_record
end

Given /^I have a saved instance of "([^\"]*)" with attributes:$/ do |klass, table|
  attributes = table.rows_hash
  @instance = klass.constantize.new
  attributes.each { |k, v| @instance.write_attribute(k, v) }
  @instance.save!
  @instance.should_not be_a_new_record
end

When /^I create an instance of "([^\"]*)"$/ do |klass|
  @instance = klass.constantize.new
end

When /^I create an instance of "([^\"]*)" with:$/ do |klass, table|
  attributes = table.rows_hash
  @instance = klass.constantize.new(attributes)
end

Then /^there should be no document at "([^\"]*)"$/ do |uri|
  When "I GET \"#{uri}\""
  Then "a \"Recliner::DocumentNotFound\" exception should be raised"
end

Then /^the instance should autogenerate an id$/ do
  @instance.id.should_not be_blank
end

Then /^the instance should be a new record$/ do
  @instance.should be_new_record
end

Then /^the instance should have a revision matching "([^\"]*)"$/ do |revision|
  @instance.rev.should match(revision)
end

Then /^the instance should not have a revision$/ do
  @instance.rev.should be_nil
end

When /^I save the instance$/ do
  @instance.save
end

When /^I save! the instance$/ do
  record_exception { @instance.save! }
end

When /^I delete the instance$/ do
  record_exception { @instance.delete }
end

When /^I destroy the instance$/ do
  record_exception { @instance.destroy }
end

Then /^the instance should not be a new record$/ do
  @instance.should_not be_new_record
end

Then /^the instance should be read only$/ do
  @instance.should be_read_only
end

When /^I set its (\w+) to "([^\"]*)"$/ do |field, value|
  field = "rev" if field == "revision"
  @instance.send("#{field}=", value)
end

Then /^the instance should have (\w+) "([^\"]*)"$/ do |field, value|
  @instance.send(field).should == value
end

Then /^there should be a document at "([^\"]*)" with:$/ do |uri, hash|
  When "I GET \"#{uri}\""
  
  eval(hash).each do |k, v|
    @result[k].should == v
  end
end

Given /^a "([^\"]*)" document exists at "([^\"]*)"$/ do |klass, uri|
  hash = { :class => klass }.inspect
  Given "a document exists at \"#{uri}\" with:", hash
end

Given /^a document exists at "([^\"]*)" with:$/ do |uri, hash|
  RestClient.put(uri, eval(hash).to_json)
end

When /^I load the "([^\"]*)" instance with id "([^\"]*)"$/ do |klass, id|
  @instance = klass.constantize.load(id)
end

When /^I load! the "([^\"]*)" instance with id "([^\"]*)"$/ do |klass, id|
  @instance = record_exception { klass.constantize.load!(id) }
end

Then /^the instance should be nil$/ do
  @instance.should be_nil
end

When /^I load the "([^\"]*)" instances with ids "([^\"]*)"$/ do |klass, ids|
  ids = ids.split(/, /)
  @instances = klass.constantize.load(*ids)
end

When /^I load! the "([^\"]*)" instances with ids "([^\"]*)"$/ do |klass, ids|
  ids = ids.split(/, /)
  @instances = record_exception { klass.constantize.load!(*ids) }
end

Then /^instance (\d+) (.*)$/ do |instance, expectation|
  @instance = @instances[instance.to_i-1]
  Then "the instance #{expectation}"
end

Given /^the "([^\"]*)" with id "([^\"]*)" is updated elsewhere$/ do |klass, id|
  instance = klass.constantize.load(id)
  instance.save
end

Then /^the instance should be valid$/ do
  @instance.should be_valid
end

Then /^the instance should save$/ do
  @instance.save.should be_true
end

Then /^the instance should not be valid$/ do
  @instance.should_not be_valid
end

Then /^the instance should not save$/ do
  @instance.save.should be_false
end

Then /^its errors should be empty$/ do
  @instance.valid?
  @instance.errors.should be_empty
end

Then /^its errors should include "([^\"]*)"$/ do |error|
  @instance.valid?
  @instance.errors.full_messages.should include(error)
end

Then /^it should have (\d+) error$/ do |num_errors|
  @instance.valid?
  @instance.errors.size.should == num_errors.to_i
end
