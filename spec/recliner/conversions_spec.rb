require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Recliner
  describe Conversions do
    after(:each) do
      Dir[File.dirname(__FILE__) + "/../../lib/recliner/conversions/*.rb"].each { |filename| load filename }
    end
    
    context "no conversions registered" do
      before(:each) do
        Conversions.clear!
      end
      
      it "should raise Recliner::Conversions::ConversionError on #convert" do
        lambda { Conversions.convert('abc', :foo) }.should raise_error(Recliner::Conversions::ConversionError, 'No registered conversion from String to :foo')
      end
      
      it "should raise Recliner::Conversions::ConversionError on #convert!" do
        lambda { Conversions.convert!('abc', :foo) }.should raise_error(Recliner::Conversions::ConversionError, 'No registered conversion from String to :foo')
      end
    end
    
    context "conversion for class registered" do
      before(:each) do
        Conversions.clear!
        Conversions.register(String, :foo) do |string|
          "foo #{string}"
        end
      end
      
      it "should convert string using conversion block" do
        Conversions.convert('123', :foo).should == 'foo 123'
        Conversions.convert!('123', :foo).should == 'foo 123'
      end
    end
    
    context "conversion for ancestor class registered" do
      before(:each) do
        Conversions.clear!
        Conversions.register(Object, :foo) do |string|
          "foo #{string} from object"
        end
      end
      
      it "should convert string using conversion block" do
        Conversions.convert('123', :foo).should == 'foo 123 from object'
        Conversions.convert!('123', :foo).should == 'foo 123 from object'
      end
    end
    
    context "conversion for class and ancestor class registered" do
      before(:each) do
        Conversions.clear!
        Conversions.register(Object, :foo) do |string|
          "foo #{string} from object"
        end
        Conversions.register(String, :foo) do |string|
          "foo #{string}"
        end
      end
      
      it "should use the conversion block for the specific class" do
        Conversions.convert('123', :foo).should == 'foo 123'
        Conversions.convert!('123', :foo).should == 'foo 123'
      end
    end
    
    context "conversion block raises exception" do
      before(:each) do
        Conversions.clear!
        Conversions.register(String, :foo) do |string|
          raise 'some error'
        end
      end
      
      specify "#convert should return nil" do
        Conversions.convert('123', :foo).should be_nil
      end
      
      specify "#convert! should raise Recliner::Conversions::ConversionError" do
        lambda { Conversions.convert!('123', :foo) }.should raise_error(Recliner::Conversions::ConversionError, 'Conversion block raised exception')
      end
    end
    
    describe "built-in conversions" do
      describe "to couch" do
        def convert(value)
          Conversions.convert!(value, :couch)
        end
        
        specify "nil remains nil" do
          convert(nil).should be_nil
        end
        
        specify "strings remain strings" do
          convert("hello").should == "hello"
          convert("goodbye").should == "goodbye"
        end
        
        specify "booleans remain booleans" do
          convert(true).should == true
          convert(false).should == false
        end
        
        specify "integers remain integers" do
          convert(0).should == 0
          convert(36).should == 36
          convert(999).should == 999
        end
        
        specify "floats remain floats" do
          convert(0.5).should == 0.5
          convert(123.456).should == 123.456
        end
        
        specify "dates are converted to strings" do
          convert(Date.parse("2009/07/30")).should == "2009/07/30"
        end
        
        specify "times are converted to strings" do
          convert(Time.parse("2009/07/30 12:16:27 +0930")).should == "2009/07/30 12:16:27 +0930"
        end
        
        context "on array" do
          it "should convert each value" do
            convert([Date.parse("2009/07/30"), Time.parse("2009/07/30 12:16:27 +0930")]).should ==
              ["2009/07/30", "2009/07/30 12:16:27 +0930"]
          end
        end
        
        context "on hash" do
          it "should convert keys to strings" do
            convert({
              :abc => 123,
              45 => 99,
              Object => 'the object'
            }).should == {
              'abc' => 123,
              '45' => 99,
              'Object' => 'the object'
            }
          end
          
          it "should convert values" do
            convert({ 'hello' => Date.parse("2009/07/30") }).should ==
              { 'hello' => "2009/07/30" }
          end
        end
      end
      
      describe "from couch" do
        def convert(value, type)
          Conversions.convert!(value, type, :source => :couch)
        end
        
        specify "hash should return itself" do
          hash = {
            'abc' => 123,
            '45' => 99,
            'Object' => 'the object'
          }
          
          convert(hash, Hash).should == hash
        end
        
        specify "array should return itself" do
          array = ['1', '2', 3, 4.0]
          convert(array, Array).should == array
        end
        
        specify "integers remain integers" do
          convert(0, Integer).should == 0
          convert(36, Integer).should == 36
          convert(999, Integer).should == 999
        end
        
        specify "floats remain floats" do
          convert(0.5, Float).should == 0.5
          convert(123.456, Float).should == 123.456
        end
        
        specify "strings remaing strings" do
          convert('hello', String).should == 'hello'
          convert('goodbye', String).should == 'goodbye'
        end
        
        context "to Time" do
          specify "time strings should be converted to Time objects" do
            convert("2009/07/30 12:16:27 +0930", Time).should == Time.parse("2009/07/30 12:16:27 +0930")
          end
        
          specify "nil should remain nil" do
            convert(nil, Time).should be_nil
          end
        end
        
        context "to Date" do
          specify "date strings should be converted to Time objects" do
            convert("2009/07/30", Date).should == Date.parse("2009/07/30")
          end

          specify "nil should remain nil" do
            convert(nil, Date).should be_nil
          end
        end
        
        context "to Boolean" do
          specify "nil remains nil" do
            convert(nil, Boolean).should be_nil
          end

          specify "booleans remain booleans" do
            convert(true, Boolean).should == true
            convert(false, Boolean).should == false
          end

          specify "strings are converted to booleans" do
            convert('true', Boolean).should == true
            convert('1', Boolean).should == true

            convert('false', Boolean).should == false
            convert('0', Boolean).should == false
          end

          specify "integers are converted to booleans" do
            convert(1, Boolean).should == true
            convert(0, Boolean).should == false
          end
        end
      end
    end
  end
end
