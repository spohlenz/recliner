require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Core extensions" do
  describe "#to_couch" do
    context "on hash" do
      it "should convert keys to strings" do
        {
          :abc => 123,
          45 => 99,
          Object => 'the object'
        }.to_couch.should == {
          'abc' => 123,
          '45' => 99,
          'Object' => 'the object'
        }
      end
      
      it "should call to_couch on values" do
        value = stub('value', :to_couch => 'couchified value')
        
        { 'hello' => value }.to_couch.should ==
          { 'hello' => 'couchified value' }
      end
    end
    
    context "on array" do
      it "should call to_couch on each element" do
        value1 = stub('value', :to_couch => 'couchified value 1')
        value2 = stub('value', :to_couch => 'couchified value 2')
        
        [value1, value2].to_couch.should ==
          ['couchified value 1', 'couchified value 2']
      end
    end
    
    context "on time" do
      it "should convert to string" do
        Time.parse("2009/07/30 12:16:27 +0930").to_couch.should == "2009/07/30 12:16:27 +0930"
      end
    end
    
    context "on date" do
      it "should convert to string" do
        Date.parse("2009/07/30").to_couch.should == "2009/07/30"
      end
    end
    
    context "on integer" do
      it "should return itself" do
        0.to_couch.should == 0
        36.to_couch.should == 36
        999.to_couch.should == 999
      end
    end
    
    context "on float" do
      it "should return itself" do
        0.5.to_couch.should == 0.5
        123.456.to_couch.should == 123.456
      end
    end
    
    context "on boolean" do
      it "should return itself" do
        true.to_couch.should == true
        false.to_couch.should == false
      end
    end
    
    context "on string" do
      it "should return itself" do
        "hello".to_couch.should == "hello"
        "goodbye".to_couch.should == "goodbye"
      end
    end
    
    context "on nil" do
      it "should return nil" do
        nil.to_couch.should == nil
      end
    end
  end
end
