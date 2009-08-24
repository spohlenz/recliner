require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    describe "#write_attribute" do
      context "internal attribute same as property name" do
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
      
      context "internal attribute different from property name" do
        before(:each) do
          subject.properties = {
            :foo => Recliner::Property.new('foo', String, '_internal', nil)
          }
        end
        
        it "should set the attribute hash" do
          subject.write_attribute(:foo, 'set foo')
          subject.attributes['_internal'].should == 'set foo'
        end
      end
      
      context "no property" do
        before(:each) do
          subject.properties = {}
        end
        
        it "should set the attribute hash" do
          subject.write_attribute(:foo, 'set foo')
          subject.attributes['foo'].should == 'set foo'
        end
      end
      
      describe "type casting" do
        context "on Date property" do
          define_recliner_document :TestDocument do
            property :the_date, Date
          end
        
          context "set to a valid date string" do
            it "should typecast the string to a date" do
              subject.the_date = '2009-10-1'
              subject.the_date.should == Date.new(2009, 10, 1)
            
              subject.the_date = '2008/4/24'
              subject.the_date.should == Date.new(2008, 4, 24)
            end
          end
        
          context "set to an invalid date string" do
            it "should return nil" do
              subject.the_date = 'foobar'
              subject.the_date.should be_nil
            end
          end
        
          context "set to a date" do
            it "should return the date" do
              subject.the_date = Date.new(2009, 10, 1)
              subject.the_date.should == Date.new(2009, 10, 1)
            end
          end
        end
      end
    end
  end
end
