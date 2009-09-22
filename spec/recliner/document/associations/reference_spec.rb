require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  module Associations
    describe Reference do
      it "should load from couch" do
        r = Reference.from_couch('abc-123')
        r.id.should == 'abc-123'
      end
      
      it "should parse from id" do
        r = Reference.parse('abc-123')
        r.id.should == 'abc-123'
      end
      
      context "without an id" do
        subject { Reference.new }
        
        it "should serialize to couch" do
          subject.to_couch.should be_nil
        end
        
        it "should be equal to another nil reference" do
          subject.should == Reference.new
        end
        
        it "should not be equal to a reference with an id" do
          subject.should_not == Reference.new('12345')
        end
        
        it "should show nil when inspecting" do
          subject.inspect.should == "nil"
        end
        
        it "should have a nil target" do
          subject.target.should be_nil
        end
        
        it "should convert to nil on to_s" do
          subject.to_s.should be_nil
        end
      end
      
      context "with an id" do
        subject { Reference.new('12345') }
        
        it "should have an id accessor" do
          subject.id.should == '12345'
        end
        
        it "should serialize to couch" do
          subject.to_couch.should == '12345'
        end
        
        it "should show the id when inspecting" do
          subject.inspect.should == "12345"
        end
        
        it "should be equal to another reference with the same id" do
          subject.should == Reference.new('12345')
        end
        
        it "should not be equal to another reference with a different id" do
          subject.should_not == Reference.new('23456')
        end
        
        it "should convert to string" do
          subject.to_s.should == '12345'
        end
        
        describe "#target" do
          before(:each) do
            @target = mock('target')
          end
          
          it "should load the target" do
            Recliner::Document.should_receive(:load!).with('12345').and_return(@target)
            subject.target.should == @target
          end
          
          it "should cache the target" do
            Recliner::Document.should_receive(:load!).once.and_return(@target)
            subject.target
            subject.target
          end
        end
      end
      
      describe "#replace" do
        subject { Reference.new }
        
        before(:each) do
          @target = mock('target', :id => 'target-id')
          subject.replace(@target)
        end
        
        it "should update the id" do
          subject.id.should == 'target-id'
        end
        
        it "should set the target" do
          Recliner::Document.should_not_receive(:load!)
          subject.target.should == @target
        end
      end
      
      describe "#reload" do
        subject { Reference.new('12345') }
        
        before(:each) do
          @target = mock('new target')
          Recliner::Document.stub!(:load!).and_return(@target)
          
          subject.instance_variable_set("@target", mock('old target'))
          subject.reload
        end
        
        it "should clear the target" do
          subject.target.should == @target
        end
      end
    end
  end
end
