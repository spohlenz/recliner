require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class PropertyDocument < Recliner::Document
  property :normal_property, String
  property :property_with_default_value, String, :default => 'the default'
  property :property_with_default_lambda_value, String, :default => lambda { 'hello' }
  property :property_with_default_lambda_value_yielding_doc, String, :default => lambda { |d| d.class.to_s }
  
  #property :nested do
  #  property :first, String
  #  property :second, String
  #end
  
  property :a_fixnum, Fixnum
  property :a_float, Float
  property :a_time, Time
  property :a_date, Date
  property :a_hash, Hash
  property :a_boolean, Boolean
  property :a_custom_class, MyCustomClass
end

describe "Basic properties" do
  subject { PropertyDocument.new }
  
  it "should create accessors for properties" do
    subject.normal_property = 'a string'
    subject.normal_property.should == 'a string'
  end
  
  it "should create query methods for properties" do
    subject.normal_property = nil
    subject.normal_property?.should be_false
    
    subject.normal_property = ''
    subject.normal_property?.should be_false
    
    subject.normal_property = 'some string'
    subject.normal_property?.should be_true
  end
  
  it "should allow getting properties using hash syntax []" do
    subject.normal_property = 'a string'
    subject[:normal_property].should == 'a string'
  end
  
  it "should allow setting properties using hash syntax []=" do
    subject[:normal_property] = 'a string'
    subject.normal_property.should == 'a string'
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
  
  it "should support default procs/lambdas for properties" do
    subject.property_with_default_lambda_value.should == 'hello'
  end
  
  it "should yield document instance to default procs/lambdas" do
    subject.property_with_default_lambda_value_yielding_doc.should == 'PropertyDocument'
  end
  
  it "should support nested properties"
  
  describe "Property serialization" do
    subject { PropertyDocument.new }
    
    it { should serialize(:a_fixnum).to(78) }
    it { should serialize(:a_float).to(5.4) }
    it { should serialize(:a_time).to(Time.now) }
    it { should serialize(:a_date).to(Date.today) }
    it { should serialize(:a_hash).to({ 'num' => 5, 'str' => 'abc' }) }
    it { should serialize(:a_boolean).to(true) }
    it { should serialize(:a_boolean).to(false) }
    it { should serialize(:a_custom_class).to(MyCustomClass.new('Hello', 123)) }
  end
end
