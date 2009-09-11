require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Core extensions" do
  describe "#from_couch" do
    context "Hash" do
      it "should return itself" do
        hash = {
          'abc' => 123,
          '45' => 99,
          'Object' => 'the object'
        }
        
        Hash.from_couch(hash).should == hash
      end
    end
    
    context "Array" do
      it "should return itself" do
        array = ['1', '2', 3, 4.0]
        Array.from_couch(array).should == array
      end
    end
    
    context "Time" do
      it "should convert to time" do
        Time.from_couch("2009/07/30 12:16:27 +0930").should == Time.parse("2009/07/30 12:16:27 +0930")
      end
      
      context "when nil" do
        it "should return nil" do
          Time.from_couch(nil).should == nil
        end
      end
    end
    
    context "Date" do
      it "should convert to date" do
        Date.from_couch("2009/07/30").should == Date.parse("2009/07/30")
      end
      
      context "when nil" do
        it "should return nil" do
          Date.from_couch(nil).should == nil
        end
      end
    end
    
    context "Integer" do
      it "should return itself" do
        Integer.from_couch(0).should == 0
        Integer.from_couch(36).should == 36
        Integer.from_couch(999).should == 999
      end
    end
    
    context "Float" do
      it "should return itself" do
        Float.from_couch(0.5).should == 0.5
        Float.from_couch(123.456).should == 123.456
      end
    end
    
    context "Boolean" do
      context "given nil" do
        it "should return false" do
          Boolean.from_couch(nil).should == false
        end
      end
      
      context "given a boolean" do
        it "should return itself" do
          Boolean.from_couch(true).should == true
          Boolean.from_couch(false).should == false
        end
      end
      
      context "given a string" do
        it "should convert to a boolean" do
          Boolean.from_couch('true').should == true
          Boolean.from_couch('1').should == true
          
          Boolean.from_couch('false').should == false
          Boolean.from_couch('0').should == false
        end
      end
      
      context "given an integer" do
        it "should convert to a boolean" do
          Boolean.from_couch(1).should == true
          Boolean.from_couch(0).should == false
        end
      end
    end
    
    context "String" do
      it "should return itself" do
        String.from_couch('hello').should == 'hello'
        String.from_couch('goodbye').should == 'goodbye'
      end
    end
  end
end
