require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    describe "#write_attribute" do
      context "internal attribute same as attribute name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, 'foo', nil)
          }
        end
        
        it "should set the attribute hash" do
          subject.write_attribute(:foo, 'set foo')
          subject.attributes['foo'].should == 'set foo'
        end
      end
      
      context "internal attribute different from attribute name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, 'internal', nil)
          }
        end
        
        it "should set the attribute hash" do
          subject.write_attribute(:foo, 'set foo')
          subject.attributes['foo'].should == 'set foo'
        end
      end
    end
  end
end
