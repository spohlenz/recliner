Given /^a map view named "([^\"]*)" exists at "([^\"]*)":$/ do |name, uri, function|
  RestClient.put(uri, { :views => { name => { :map => function } } }.to_json)
end

Given /^there are \d+ users with names:$/ do |table|
  table.raw.each do |row|
    User.create!(:name => row.first)
  end
end

When /^I invoke the "([^\"]*)" view "([^\"]*)" with no arguments$/ do |klass, view|
  @result = klass.constantize.send(view)
end

Then /^the result should be an Array of (\d+) (\w+) instances$/ do |number, klass|
  @result.size.should == number
  @result.each { |i| i.should be_an_instance_of(klass) }
end

Then /^the result should be empty$/ do
  @result.should be_empty
end
