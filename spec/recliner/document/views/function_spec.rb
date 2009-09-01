require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe ViewFunction::Map do
    it "should wrap a function body in a function signature and braces" do
      map = ViewFunction::Map.new('map function body')
      
      map.to_s.should == 'function(doc) { map function body }'
      map.to_couch.should == 'function(doc) { map function body }'
    end
    
    it "should not rewrap a function body which already has a signature and braces" do
      map = ViewFunction::Map.new('function(doc) { map function body }')
      
      map.to_s.should == 'function(doc) { map function body }'
      map.to_couch.should == 'function(doc) { map function body }'
    end
    
    it "should be equal to another map function with identical body" do
      map1 = ViewFunction::Map.new('map function body')
      map2 = ViewFunction::Map.new('function(doc) { map function body }')
      
      map1.should == map2
    end
    
    it "should not be equal to another map function with a different body" do
      map1 = ViewFunction::Map.new('map function body')
      map2 = ViewFunction::Map.new('different function body')
      
      map1.should_not == map2
    end
  end
    
  describe ViewFunction::Reduce do
    it "should wrap a function body in a function signature and braces" do
      reduce = ViewFunction::Reduce.new('reduce function body')
      
      reduce.to_s.should == 'function(keys, values, rereduce) { reduce function body }'
      reduce.to_couch.should == 'function(keys, values, rereduce) { reduce function body }'
    end
    
    it "should not rewrap a function body which already has a signature and braces" do
      reduce = ViewFunction::Reduce.new('function(keys, values, rereduce) { reduce function body }')
      
      reduce.to_s.should == 'function(keys, values, rereduce) { reduce function body }'
      reduce.to_couch.should == 'function(keys, values, rereduce) { reduce function body }'
    end
    
    it "should be equal to another reduce function with identical body" do
      reduce1 = ViewFunction::Reduce.new('reduce function body')
      reduce2 = ViewFunction::Reduce.new('function(keys, values, rereduce) { reduce function body }')
      
      reduce1.should == reduce2
    end
    
    it "should not be equal to another reduce function with a different body" do
      reduce1 = ViewFunction::Reduce.new('reduce function body')
      reduce2 = ViewFunction::Reduce.new('different function body')
      
      reduce1.should_not == reduce2
    end
  end
end
