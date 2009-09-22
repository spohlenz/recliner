require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Property do
    subject { Property.new('name', String, 'as', 'default') }
  
    it "should have attribute readers" do
      subject.name.should == 'name'
      subject.type.should == String
      subject.as.should == 'as'
      subject.default.should == 'default'
    end
  
    describe "#default_value" do
      context "with no default set" do
        it "should return nil" do
          subject.default = nil
          subject.default_value(nil).should == nil
        end
      end
  
      context "with a string as default" do
        it "should return the string" do
          subject.default_value(nil).should == 'default'
        end
      end
  
      context "with a callable object as default" do
        context "callable references yielded value" do
          it "should return the result of calling the proc/lambda with the object" do
            subject.default = lambda { |a| a }
            subject.default_value(7).should == 7
          end
        end
    
        context "callable does not reference yielded value" do
          it "should return the result of calling the proc/lambda" do
            subject.default = lambda { 3 }
            subject.default_value(nil).should == 3
          end
        end
      end
      
      context "with a duplicable default object" do
        before(:each) do
          @dup = mock('duplicate')
          subject.default = mock('duplicable object', :dup => @dup)
        end
        
        it "should duplicate and return the object" do
          subject.default_value(nil).should == @dup
        end
      end
    end
  
    describe "#type_cast" do
      context "Date property" do
        subject { Property.new(:date, Date, :date, nil) }
      
        it "should not change a Date value" do
          subject.type_cast(Date.new(2009, 10, 1)).should == Date.new(2009, 10, 1)
        end
      
        it "should convert a Time to a Date" do
          subject.type_cast(Time.utc(2010, 5, 15, 1, 2, 3, 4)).should == Date.new(2010, 5, 15)
          subject.type_cast(Time.now).should == Date.today
        end
      
        it "should convert a DateTime to a Date" do
          subject.type_cast(DateTime.civil(2010, 5, 15, 1, 2, 3, 4)).should == Date.new(2010, 5, 15)
          subject.type_cast(DateTime.now).should == Date.today
        end
      
        it "should convert a valid date string to a Date" do
          subject.type_cast("2009-10-1").should == Date.new(2009, 10, 1)
          subject.type_cast("2008/4/23").should == Date.new(2008, 4, 23)
        end
      
        it "should return nil if given nil" do
          subject.type_cast(nil).should be_nil
        end
      
        it "should return nil if string given and cannot be parsed" do
          subject.type_cast('').should be_nil
          subject.type_cast('foobar').should be_nil
          subject.type_cast('2009-123-123').should be_nil
          subject.type_cast('2009-13-32').should be_nil
        end
      end
    
      context "Time property" do
        subject { Property.new(:time, Time, :time, nil) }
      
        it "should not change a Time value" do
          t = Time.now
          subject.type_cast(t).should == t
        end
      
        it "should convert a Date to a Time" do
          subject.type_cast(Date.new(2009, 10, 1)).should == Time.local(2009, 10, 1)
        end
      
        it "should convert a DateTime to a Time" do
          subject.type_cast(DateTime.civil(2010, 5, 15, 1, 2, 3)).should == Time.utc(2010, 5, 15, 1, 2, 3)
        end
      
        it "should convert valid time string to a Time" do
          subject.type_cast("2009-10-1 12:30:45").should == Time.local(2009, 10, 1, 12, 30, 45)
        end
      
        it "should return nil if given nil" do
          subject.type_cast(nil).should be_nil
        end
      
        it "should return nil if string given and cannot be parsed" do
          subject.type_cast('').should be_nil
          subject.type_cast('foobar').should be_nil
          subject.type_cast('2009-123-123').should be_nil
          subject.type_cast('2009-13-32').should be_nil
        end
      end
    
      context "Boolean property" do
        subject { Property.new(:boolean, Boolean, :boolean, nil) }
      
        it "should convert 'true' values to true" do
          subject.type_cast(true).should be_true
          subject.type_cast('true').should be_true
          subject.type_cast('TRUE').should be_true
          subject.type_cast('T').should be_true
          subject.type_cast('yes').should be_true
          subject.type_cast('YES').should be_true
          subject.type_cast('Y').should be_true
          subject.type_cast('1').should be_true
          subject.type_cast(1).should be_true
        end
      
        it "should convert 'false' values to false" do
          subject.type_cast(false).should be_false
          subject.type_cast('false').should be_false
          subject.type_cast('FALSE').should be_false
          subject.type_cast('F').should be_false
          subject.type_cast('no').should be_false
          subject.type_cast('NO').should be_false
          subject.type_cast('N').should be_false
          subject.type_cast('0').should be_false
          subject.type_cast(0).should be_false
        end
      
        it "should convert other values to nil" do
          subject.type_cast(124).should be_nil
          subject.type_cast('trueish').should be_nil
          subject.type_cast('falsish').should be_nil
          subject.type_cast('yes and no').should be_nil
          subject.type_cast('12').should be_nil
        end
      end
    
      context "String property" do
        subject { Property.new(:string, String, :string, nil) }
      
        it "should not alter strings" do
          subject.type_cast('').should == ''
          subject.type_cast('abc').should == 'abc'
        end
      
        it "should convert numbers to strings" do
          subject.type_cast(1).should == '1'
          subject.type_cast(99).should == '99'
          subject.type_cast(12.345).should == '12.345'
        end
      
        it "should convert a Time to a String" do
          subject.type_cast(Time.local(2009, 10, 1, 12, 30, 45)).should == '2009-10-01 12:30:45 +0930'
        end
      
        it "should convert a Date to a String" do
          subject.type_cast(Date.new(2009, 10, 1)).should == '2009-10-01'
        end
      
        it "should return nil when nil given" do
          subject.type_cast(nil).should be_nil
        end
      end
    
      context "Integer property" do
        subject { Property.new(:integer, Integer, :integer, nil) }
      
        it "should not alter integers" do
          subject.type_cast(0).should == 0
          subject.type_cast(1).should == 1
          subject.type_cast(34).should == 34
        end
      
        it "should convert floats to integers (truncate)" do
          subject.type_cast(0.123).should == 0
          subject.type_cast(1.234).should == 1
          subject.type_cast(99.999).should == 99
        end
      
        it "should convert strings to integers" do
          subject.type_cast("1-permalink").should == 1
          subject.type_cast("34.5 is magic").should == 34
          subject.type_cast("0").should == 0
          subject.type_cast(" 0").should == 0
        end
      
        it "should return nil for strings not beginning with a number" do
          subject.type_cast("permalink").should be_nil
          subject.type_cast("a string with 99").should be_nil
        end
      
        it "should return nil when nil given" do
          subject.type_cast(nil).should be_nil
        end
      end
    
      context "Float property" do
        subject { Property.new(:float, Float, :float, nil) }
      
        it "should not alter floats" do
          subject.type_cast(1.2).should == 1.2
          subject.type_cast(0.999).should == 0.999
          subject.type_cast(533.123).should == 533.123
        end
      
        it "should convert strings to floats" do
          subject.type_cast("4.3").should == 4.3
          subject.type_cast("99.999").should == 99.999
          subject.type_cast(".1234").should == 0.1234
          subject.type_cast(".000").should == 0.0
          subject.type_cast(" .000").should == 0.0
        end
      
        it "should return nil for strings not beginning with a number or period" do
          subject.type_cast("hello").should be_nil
          subject.type_cast("a string with 99.9").should be_nil
        end
      
        it "should return nil when nil given" do
          subject.type_cast(nil).should be_nil
        end
      end
    
      context "custom property type" do
        class CustomType
          attr_reader :name
        
          def initialize(name="John")
            @name = name
          end
        
          def self.parse(str)
            new(str)
          end
        end
      
        subject { Property.new(:custom, CustomType, :custom, nil) }
      
        it "should not alter instances of custom type" do
          obj = CustomType.new
          subject.type_cast(obj).should equal(obj)
        end
      
        it "should convert a String to a custom type instance" do
          result = subject.type_cast("Fred")
        
          result.should be_an_instance_of(CustomType)
          result.name.should == "Fred"
        end
      
        it "should return nil when nil given" do
          subject.type_cast(nil).should be_nil
        end
      end
    end
  end
end
