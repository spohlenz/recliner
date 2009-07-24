require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Recliner::Document#Set" do
  before(:each) do
    @set = Recliner::Document.Set(MyCustomClass)
  end
  
  it "should set the Set type" do
    @set.type.should == MyCustomClass
  end
  
  it "should load correctly from couch representation" do
    data = [
      { 'a' => 'Hello', 'b' => 123 },
      { 'a' => 456, 'b' => 'Ciao' }
    ]
    
    result = @set.from_couch(data)
    result.should be_a_kind_of(Recliner::Document::Set)
    
    result[0].should == MyCustomClass.new('Hello', 123)
    result[1].should == MyCustomClass.new(456, 'Ciao')
  end
  
  it "should load an empty set for a null couch representation" do
    result = @set.from_couch(nil)
    result.should be_a_kind_of(Recliner::Document::Set)
  end
  
  describe "An instance of the Set" do
    subject { @set.new }
    
    it "should be a map" do
      subject.should be_a_kind_of(Recliner::Document::Set)
    end
    
    it "should be an array" do
      subject.should be_a_kind_of(Array)
    end
    
    it "should serialize to json representation" do
      subject << MyCustomClass.new('Hello', 123)
      subject << MyCustomClass.new(456, 'Ciao')
      
      subject.to_couch.should == [{ :a => 'Hello', :b => 123 }, { :a => 456, :b => 'Ciao'}]
    end
  end
end
