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
        TestDocument.model_properties.should == TestDocument.properties.slice(:foo, :bar)
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
  
  describe Property do
    subject { Property.new('name', 'type', 'as', 'default') }
    
    it "should have attribute readers" do
      subject.name.should == 'name'
      subject.type.should == 'type'
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
          subject.type_cast(Time.local(2009, 10, 1, 12, 30, 45)).should == 'Thu Oct 01 12:30:45 +0930 2009'
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
    end
  end
end
