require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    describe "#read_attribute" do
      context "internal attribute same as property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, 'foo', nil)
          }
          subject.stub(:attributes).and_return('foo' => 'value of foo')
        end
        
        it "should return the attribute value" do
          subject.read_attribute(:foo).should == 'value of foo'
        end
      end
      
      context "internal attribute different from property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, '_internal', nil)
          }
          subject.stub(:attributes).and_return('_internal' => 'value of foo')
        end
        
        it "should return the attribute value" do
          subject.read_attribute(:foo).should == 'value of foo'
        end
      end
      
      context "no property" do
        before(:each) do
          subject.properties = {}
          subject.stub!(:attributes).and_return('foo' => 'value of foo')
        end
        
        it "should return the attribute value" do
          subject.read_attribute(:foo).should == 'value of foo'
        end
      end
    end
  end
end
