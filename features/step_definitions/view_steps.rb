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

When /^I invoke the "([^\"]*)" view "([^\"]*)" with key "([^\"]*)"$/ do |klass, view, key|
  @result = klass.constantize.send(view, key)
end

When /^I invoke the "([^\"]*)" view "([^\"]*)" with keys "([^\"]*)"$/ do |klass, view, keys|
  @result = klass.constantize.send(view, *keys.split(', '))
end

When /^I invoke the "([^\"]*)" view "([^\"]*)" with options:$/ do |klass, view, table|
  options = table.raw.inject({}) { |result, (k, v)|
    result[k] = case v
      when 'true'
        true
      when 'false'
        false
      else
        v
      end
    
    result
  }
  
  @result = klass.constantize.send(view, options)
end

When /^I invoke the "([^\"]*)" view "([^\"]*)" with "([^\"]*)"$/ do |klass, view, argument|
  @result = klass.constantize.send(view, argument)
end

Then /^the result should be an Array of (\d+) (\w+) instances?$/ do |number, klass|
  @result.size.should == number.to_i
  @result.each { |i| i.should be_an_instance_of(klass.constantize) }
end

Then /^the result should be empty$/ do
  @result.should be_empty
end

Then /^the user names should equal:$/ do |table|
  table.raw.each_with_index do |row, i|
    @result[i].name.should == row.first
  end
end
