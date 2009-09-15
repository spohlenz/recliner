When /^I set its (\w+) to the "([^\"]*)" with id "([^\"]*)"$/ do |association, model, id|
  @instance.send("#{association}=", model.constantize.load!(id))
end

Then /^its "([^\"]*)" should be the "([^\"]*)" with id "([^\"]*)"$/ do |association, model, id|
  @instance.send(association).should be_an_instance_of(model.constantize)
  @instance.send(association).id.should == id
end
