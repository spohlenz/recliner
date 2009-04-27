require File.dirname(__FILE__) + '/../spec_helper'

class PropertyDocument < Recliner::Document
  property :normal_property, String
  property :property_with_default_value, String, :default => 'the default'
  
  property :nested do
    property :first, String
    property :second, String
  end
  
  property :a_fixnum, Fixnum
  property :a_float, Float
  property :a_time, Time
  property :a_date, Date
  property :a_hash, Hash
end

describe "Basic properties" do
  subject { PropertyDocument.new }
  
  it "should create accessors for properties" do
    subject.should respond_to(:normal_property)
    subject.should respond_to(:normal_property=)
  end
  
  it "should save the property value to the database" do
    subject.normal_property = 'Testing, 123'
    subject.id = '123'
    subject.save
    
    CouchDB.should have_document({ :normal_property => 'Testing, 123' }).
                   at('http://localhost:5984/recliner-test/123')
  end
  
  it "should support default values for properties" do
    subject.property_with_default_value.should == 'the default'
  end
  
  it "should support nested properties"
  
  describe "Property serialization" do
    subject { PropertyDocument.new }
    
    it { should serialize(:a_fixnum).to(78) }
    it { should serialize(:a_float).to(5.4) }
    it { t = Time.now; should serialize(:a_time).to(t) }
    it { should serialize(:a_date).to(Date.today) }
    it { should serialize(:a_hash).to({ 'num' => 5, 'str' => 'abc' }) }
  end
end
