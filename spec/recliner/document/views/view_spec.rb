require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe View do
    context "with map option" do
      subject { Recliner::View.new(:map => 'my map function') }
      
      it "should wrap map function in a Recliner::ViewFunction::Map" do
        subject.map.should be_an_instance_of(Recliner::ViewFunction::Map)
      end
      
      it "should serialize to couch" do
        subject.to_couch.should == {
          'map' => 'function(doc) { my map function }'
        }
      end
      
      it "should load from couch" do
        view = Recliner::View.from_couch({
          'map' => 'function(doc) { my map function }'
        })
        
        view.map.to_s.should == 'function(doc) { my map function }'
        view.reduce.should be_nil
      end
      
      it "should be equal to another view with the same map function and no view" do
        subject.should == Recliner::View.new(:map => 'my map function')
      end
      
      it "should not be equal to another view with the same map function but with a view" do
        subject.should_not == Recliner::View.new(:map => 'my map function', :reduce => 'some reduce function')
      end
      
      it "should not be equal to another view with a different map function" do
        subject.should_not == Recliner::View.new(:map => 'some other map function')
      end
    end
    
    context "with map and reduce options" do
      subject { Recliner::View.new(:map => 'my map function', :reduce => 'my reduce function') }
      
      it "should wrap reduce function in a Recliner::ViewFunction::Reduce" do
        subject.reduce.should be_an_instance_of(Recliner::ViewFunction::Reduce)
      end
      
      it "should serialize to couch" do
        subject.to_couch.should == {
          'map' => 'function(doc) { my map function }',
          'reduce' => 'function(keys, values, rereduce) { my reduce function }'
        }
      end
      
      it "should load from couch" do
        view = Recliner::View.from_couch({
          'map' => 'function(doc) { my map function }',
          'reduce' => 'function(keys, values, rereduce) { my reduce function }'
        })
        
        view.map.to_s.should == 'function(doc) { my map function }'
        view.reduce.to_s.should == 'function(keys, values, rereduce) { my reduce function }'
      end
      
      it "should be equal to another view with the same map and reduce functions" do
        subject.should == Recliner::View.new(:map => 'my map function', :reduce => 'my reduce function')
      end
      
      it "should not be equal to another view with a different map function" do
        subject.should_not == Recliner::View.new(:map => 'some other map function', :reduce => 'my reduce function')
      end
      
      it "should not be equal to another view with a different reduce function" do
        subject.should_not == Recliner::View.new(:map => 'my map function', :reduce => 'some other reduce function')
      end
    end
  end
end
