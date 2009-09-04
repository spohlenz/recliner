require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  module SetClassHelper
    def set_class(type)
      set_classes[type] ||= begin
        klass = Class.new(Set)
        klass.type = type
        klass
      end
    end
    
    def set_classes
      @set_classes ||= {}
    end
  end
  
  describe Set do
    include SetClassHelper
    
    describe "class" do
      it "should be equal to another Set class with the same type" do
        set_class(String).should == set_class(String)
        set_class(Date).should == set_class(Date)
      end
    
      it "should not be equal to another Set class with a different type" do
        set_class(String).should_not == set_class(Date)
      end
      
      it "should show the set types when inspected" do
        set_class(String).inspect.should == "#<Set[String]>"
        set_class(Integer).inspect.should == "#<Set[Integer]>"
        set_class(Date).inspect.should == "#<Set[Date]>"
      end
    end
    
    Examples = {
      String => { :abc => 'abc', 'Some string' => 'Some string', 123 => '123', 54.94 => '54.94', nil => nil },
      Integer => { '35' => 35, '46.4' => 46, 123.5 => 123, 99 => 99, nil => nil },
      Float => { '35.5' => 35.5, '0' => 0.0, 12 => 12.0, 45.55 => 45.55, nil => nil }
    }
    
    Examples.each do |type, conversions|
      before_type_cast = conversions.keys
      after_type_cast = conversions.values
      
      context "with type #{type}" do
        subject { set_class(type) }
        
        it "should convert values when creating" do
          set = subject[*before_type_cast]
          set.should be_an_instance_of(subject)
          after_type_cast.each_with_index do |value, i|
            set[i].should == value
          end
        end
        
        it "should load from couch representation" do
          result = subject.from_couch(after_type_cast)
          result.should be_an_instance_of(subject)
          result.should == after_type_cast
        end
        
        it "should serialize to couch representation" do
          set = subject[*after_type_cast]
          set.to_couch.should == after_type_cast
        end
        
        it "should convert values when assigning by index" do
          set = subject.new
          before_type_cast.each_with_index do |value, i|
            set[i] = value
          end
          set.should == after_type_cast
        end
        
        it "should convert values when adding" do
          set = subject.new
          result = (set + before_type_cast)
          
          result.should be_an_instance_of(subject)
          result.should == after_type_cast
        end
        
        it "should convert values when appending" do
          set = subject.new
          before_type_cast.each do |key|
            set << key
          end
          set.should == after_type_cast
        end
        
        it "should convert values when concatenating" do
          set = subject.new
          set.concat(before_type_cast)
          set.should == after_type_cast
        end
        
        it "should convert values when deleting" do
          set = subject[*after_type_cast]
          set.delete(before_type_cast.first)
          set.should == after_type_cast - [after_type_cast.first]
        end
        
        it "should convert values when getting index" do
          set = subject[*after_type_cast]
          conversions.each do |key, value|
            set.index(key).should == after_type_cast.index(value)
          end
        end
        
        it "should convert values when getting rindex" do
          set = subject[*after_type_cast]
          conversions.each do |key, value|
            set.rindex(key).should == after_type_cast.rindex(value)
          end
        end
        
        it "should convert values when inserting" do
          set = subject.new
          before_type_cast.each do |key|
            set.insert(0, key)
          end
          set.should == after_type_cast.reverse
        end
        
        it "should convert values when pushing" do
          set = subject.new
          set.push(*before_type_cast)
          set.should == after_type_cast
        end
      
        it "should convert values when unshifting" do
          set = subject.new
          set.unshift(*before_type_cast)
          set.should == after_type_cast
        end
      
        it "should inspect like an Array" do
          set = subject[*conversions.keys]
          set.inspect.should == after_type_cast.inspect
        end
      end
    end
    
    context "with custom class type" do
      class ::CustomClass
        attr_reader :name
        
        def initialize(name)
          @name = name
        end
        
        def to_couch
          { 'name' => name }
        end
        
        def self.from_couch(hash)
          new(hash['name'])
        end
        
        def ==(other)
          name == other.name
        end
      end
      
      subject { set_class(CustomClass) }
      
      it "should convert values to custom class instances when loading from couch" do
        couch    = [ { 'name' => 'abc' }, { 'name' => 'def' } ]
        expected = [ CustomClass.new('abc'), CustomClass.new('def') ]
        
        result = subject.from_couch(couch)
        result.should be_an_instance_of(subject)
        result.should == expected
      end
      
      it "should convert values to couch representation when serializing to couch" do
        set = subject.new
        set << CustomClass.new('foo')
        set << CustomClass.new('bar')
        
        set.to_couch.should == [ { 'name' => 'foo' }, { 'name' => 'bar' } ]
      end
      
      it "should raise a TypeError if an assigned value is not a custom class" do
        set = subject.new
        lambda { set << 'wrong type' }.should raise_error(TypeError, 'expected CustomClass but got String')
      end
    end
  end
  
  describe Property do
    include SetClassHelper
    
    describe "with type Set" do
      context "with no default value" do
        subject { Property.new(:set, set_class(String), :set, nil) }
        
        it "should default to a Set of the same type" do
          subject.default_value(nil).should be_an_instance_of(set_class(String))
        end
      end
      
      context "with a default value" do
        subject { Property.new(:set, set_class(String), :set, ['foo', 'bar']) }
        
        it "should default to a Set of the same type" do
          subject.default_value(nil).should be_an_instance_of(set_class(String))
        end
        
        it "should default to a Set built from the given default" do
          subject.default_value(nil).should == ['foo', 'bar']
        end
      end
    end
  end
  
  describe Document do
    describe "#Set" do
      subject { Document.Set(String) }
      
      it "should return a new subclass of Recliner::Set" do
        subject.new.should be_a_kind_of(Recliner::Set)
      end
      
      it "should set the type of the subclass" do
        subject.type.should == String
      end
      
      it "should cache classes" do
        subject.should eql(Document.Set(String))
      end
    end
    
    describe "with a Set property" do
      context "with no default value" do
        define_recliner_document :TestDocument do
          property :set_property, Set(String)
        end
        
        subject { TestDocument.new }
        
        it "should default to an empty Set" do
          subject.set_property.should == []
        end
      end
    end
  end
end
