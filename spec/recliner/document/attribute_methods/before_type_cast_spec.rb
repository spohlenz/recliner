require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    describe "#read_attribute_before_type_cast" do
      context "internal attribute same as property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, 'foo', nil)
          }
          subject.stub(:attributes_before_type_cast).and_return('foo' => 'value of foo')
        end
        
        it "should return the attribute value" do
          subject.read_attribute_before_type_cast(:foo).should == 'value of foo'
        end
      end
      
      context "internal attribute different from property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, '_internal', nil)
          }
          subject.stub(:attributes_before_type_cast).and_return('_internal' => 'value of foo')
        end
        
        it "should return the attribute value" do
          subject.read_attribute_before_type_cast(:foo).should == 'value of foo'
        end
      end
      
      context "no property" do
        before(:each) do
          subject.properties = {}
          subject.stub!(:attributes_before_type_cast).and_return('foo' => 'value of foo')
        end
        
        it "should return the attribute value" do
          subject.read_attribute_before_type_cast(:foo).should == 'value of foo'
        end
      end
    end
    
    describe "#write_attribute" do
      context "internal attribute same as property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', Date, 'foo', nil)
          }
        end
        
        it "should set attributes_before_type_cast" do
          subject.write_attribute(:foo, 'user input')
          subject.attributes_before_type_cast['foo'].should == 'user input'
        end
      end
      
      context "internal attribute different from property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', Date, '_internal', nil)
          }
        end
        
        it "should set attributes_before_type_cast" do
          subject.write_attribute(:foo, 'user input')
          subject.attributes_before_type_cast['_internal'].should == 'user input'
        end
      end
      
      context "no property" do
        before(:each) do
          subject.properties = {}
        end
        
        it "should set attributes_before_type_cast value" do
          subject.write_attribute(:foo, 'user input')
          subject.attributes_before_type_cast['foo'].should == 'user input'
        end
      end
    end
  end
end
