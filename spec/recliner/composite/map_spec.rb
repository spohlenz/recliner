require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Recliner::Document#Map" do
  before(:each) do
    @map = Recliner::Document.Map(String => MyCustomClass)
  end
  
  it "should set the from and to properties of the class" do
    @map.from.should == String
    @map.to.should == MyCustomClass
  end
  
  it "should load correctly from couch representation" do
    data = {
      'hello' => { 'a' => 'Hello', 'b' => 123 },
      'cya' => { 'a' => 456, 'b' => 'Ciao' }
    }
    
    result = @map.from_couch(data)
    
    result['hello'].should == MyCustomClass.new('Hello', 123)
    result['cya'].should == MyCustomClass.new(456, 'Ciao')
  end
  
  describe "An instance of the Map" do
    subject { @map.new }
    
    it "should be a map" do
      subject.should be_a_kind_of(Recliner::Document::Map)
    end
    
    it "should be a hash" do
      subject.should be_a_kind_of(Hash)
    end
    
    it "should serialize to json representation" do
      subject['hello'] = MyCustomClass.new('Hello', 123)
      subject['cya'] = MyCustomClass.new(456, 'Ciao')
      
      subject.to_json.should == '{"cya":{"a":456,"b":"Ciao"},"hello":{"a":"Hello","b":123}}'
    end
  end
end
