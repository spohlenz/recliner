require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    describe "#query_attribute" do
      context "internal attribute same as property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, 'foo', nil)
          }
        end
        
        context "attribute not blank" do
          before(:each) do
            subject.stub(:attributes).and_return('foo' => 'not blank')
          end
          
          it "should return true" do
            subject.query_attribute(:foo).should be_true
          end
        end
        
        context "attribute blank" do
          before(:each) do
            subject.stub(:attributes).and_return('foo' => '')
          end
          
          it "should return false" do
            subject.query_attribute(:foo).should be_false
          end
        end
      end
      
      context "internal attribute different from property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, '_internal', nil)
          }
        end
        
        context "attribute not blank" do
          before(:each) do
            subject.stub(:attributes).and_return('_internal' => 'not blank')
          end
          
          it "should return true" do
            subject.query_attribute(:foo).should be_true
          end
        end
        
        context "attribute blank" do
          before(:each) do
            subject.stub(:attributes).and_return('_internal' => '')
          end
          
          it "should return false" do
            subject.query_attribute(:foo).should be_false
          end
        end
      end
      
      context "no property" do
        before(:each) do
          subject.properties = {}
        end
        
        context "attribute not blank" do
          before(:each) do
            subject.stub(:attributes).and_return('foo' => 'not blank')
          end
          
          it "should return true" do
            subject.query_attribute(:foo).should be_true
          end
        end
        
        context "attribute blank" do
          before(:each) do
            subject.stub(:attributes).and_return('foo' => '')
          end
          
          it "should return false" do
            subject.query_attribute(:foo).should be_false
          end
        end
      end
    end
  end
end
