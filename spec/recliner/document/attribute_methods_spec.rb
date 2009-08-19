require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    before(:each) do
      TestDocument.properties = {
        :foo => Recliner::Property.new(:foo, String, 'foo', nil),
        :bar => Recliner::Property.new(:bar, Integer, 'internal', nil)
      }
    end
    
    describe "#attributes" do
      it "should be a hash" do
        subject.attributes.should be_an_instance_of(HashWithIndifferentAccess)
      end
      
      it "should memoize the hash" do
        subject.attributes.should equal(subject.attributes)
      end
      
      it "should store attributes using their name" do
        subject.foo = 'value of foo'
        subject.bar = 'value of bar'
        
        subject.attributes['foo'].should == 'value of foo'
        subject.attributes['bar'].should == 'value of bar'
      end
    end
    
    describe "#attributes=" do
      it "should send writer method for each given attribute" do
        subject.should_receive(:foo=).with('bar')
        subject.should_receive(:baz=).with(123)
        
        subject.attributes = {
          :foo => 'bar',
          :baz => 123
        }
      end
    end
    
    describe "generating attribute methods" do
      subject { TestDocument.new }
      
      context "after attribute methods are generated" do
        before(:each) do
          TestDocument.define_attribute_methods
        end
      
        it "should create a reader method for each property" do
          subject.stub(:attributes).and_return({
            'foo' => 'value for foo',
            'bar' => 99
          })
        
          subject.foo.should == 'value for foo'
          subject.bar.should == 99
        end
      
        it "should create a writer method for each property" do
          subject.foo = 'set foo'
          subject.bar = 67
        
          subject.attributes['foo'].should == 'set foo'
          subject.attributes['bar'].should == 67
        end
      
        it "should create a query method for each property" do
          subject.stub(:attributes).and_return({
            'foo' => 'value for foo',
            'bar' => nil
          })
        
          subject.foo?.should be_true
          subject.bar?.should be_false
        
          subject.stub(:attributes).and_return({
            'foo' => '',
            'bar' => 14
          })
        
          subject.foo?.should be_false
          subject.bar?.should be_true
        end
      end
    
      context "before attribute methods are generated" do
        before(:each) do
          TestDocument.undefine_attribute_methods
        end
        
        it "should generate attribute methods during respond_to?" do
          subject.should respond_to(:foo)
          TestDocument.attribute_methods_generated?.should be_true
        end
        
        it "should generate attribute methods during method_missing" do
          subject.foo
          TestDocument.attribute_methods_generated?.should be_true
        end
      end
    end
    
    describe "#to_couch" do
      context "a model with no extra properties" do
        define_recliner_document :TestDocument
        
        subject { TestDocument.new(:id => 'abc-123') }
        
        it "should return a hash containing the document class and id" do
          subject.to_couch.should == { 'class' => 'TestDocument', '_id' => 'abc-123' }
        end
      end
      
      context "a model with properties" do
        define_recliner_document :TestDocument do
          property :name, String
          property :age, Integer, :as => '_internal_age'
        end
        
        subject { TestDocument.new(:id => 'abc-123', :name => 'My name', :age => 21 )}
        
        it "should return a hash containing the document class and the model attributes (excluding the id and rev)" do
          subject.to_couch.should == {
            'class' => 'TestDocument',
            '_id' => 'abc-123',
            'name' => 'My name',
            '_internal_age' => 21
          }
        end
      end
    end
  end
end
