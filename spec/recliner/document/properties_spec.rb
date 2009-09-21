require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    it "should have default property id" do
      property = TestDocument.properties[:id]
      property.should_not be_nil
      property[:as].should == '_id'
    end
    
    it "should have default property rev" do
      property = TestDocument.properties[:rev]
      property.should_not be_nil
      property[:as].should == '_rev'
    end
    
    describe "#properties" do
      it "should be a hash" do
        TestDocument.properties.should be_a_kind_of(Hash)
      end
      
      it "should be accessible from instance" do
        TestDocument.new.properties.should == TestDocument.properties
      end
      
      it "should inherit from parent class" do
        TestDocument.properties[:abc] = 1
        child = Class.new(TestDocument)
        child.properties.should == TestDocument.properties
      end
      
      it "should not inherit from child classes" do
        child = Class.new(TestDocument)
        child.properties[:foo] = 2
        TestDocument.properties.should_not == child.properties
      end
    end
    
    describe "#model_properties" do
      it "should return all defined properties except for id and rev" do
        TestDocument.properties = {
          :id => Recliner::Property.new(:id, String, '_id', nil),
          :rev => Recliner::Property.new(:rev, String, '_rev', nil),
          :foo => Recliner::Property.new(:foo, String, 'foo', nil),
          :bar => Recliner::Property.new(:bar, Integer, 'internal', nil)
        }
        TestDocument.model_properties.should == {
          :foo => Recliner::Property.new(:foo, String, 'foo', nil),
          :bar => Recliner::Property.new(:bar, Integer, 'internal', nil)
        }
      end
    end
    
    describe "defining properties" do
      context "basic property types" do
        BasicTypes = [ String, Integer, Float, Boolean, Time, Date ]
        
        BasicTypes.each do |type|
          it "should build and add property with type #{type} to the properties hash" do
            TestDocument.property :basic, type
            TestDocument.properties[:basic].should ==
              Recliner::Property.new('basic', type, 'basic', nil)
          end
        end
      end
      
      context "property with custom :as" do
        it "should build and add the property to the properties hash" do
          TestDocument.property :custom_as, String, :as => 'internal'
          TestDocument.properties[:custom_as].should ==
            Recliner::Property.new('custom_as', String, 'internal', nil)
        end
      end
      
      context "property with default value" do
        it "should build and add the property to the properties hash" do
          TestDocument.property :default, String, :default => 'default-value'
          TestDocument.properties[:default].should ==
            Recliner::Property.new('default', String, 'default', 'default-value')
        end
      end
      
      context "nested property" do
        it "should build and add the property to the properties hash" do
          pending "Not yet implemented"
          
          TestDocument.property :with_block do
            property :inner_attribute, String
          end
        end
      end
      
      context "no type or block given" do
        it "should raise a descriptive error" do
          lambda { TestDocument.property :no_type_or_block }.should raise_error(ArgumentError, 'Either a type or block must be provided')
        end
      end
    end
  end
end
