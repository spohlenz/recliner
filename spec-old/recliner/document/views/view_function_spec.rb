require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Recliner::MapViewFunction" do
  it "should wrap the body with a javascript function definition if not given" do
    func = Recliner::MapViewFunction.new('emit(doc, null);')
    func.to_s.should == 'function(doc) { emit(doc, null); }'
  end
  
  it "should not rewrap the function if given" do
    func = Recliner::MapViewFunction.new('function(doc) { emit(doc, null); }')
    func.to_s.should == 'function(doc) { emit(doc, null); }'
  end
end

describe "Recliner::ReduceViewFunction" do
  it "should wrap the body with a javascript function definition if not given" do
    func = Recliner::ReduceViewFunction.new('return sum(values);')
    func.to_s.should == 'function(keys, values, rereduce) { return sum(values); }'
  end
  
  it "should not rewrap the function if given" do
    func = Recliner::ReduceViewFunction.new('function(keys, values, rereduce) { return sum(values); }')
    func.to_s.should == 'function(keys, values, rereduce) { return sum(values); }'
  end
end
