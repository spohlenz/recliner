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
    
    context "with type String" do
      subject { set_class(String).new }
      
      it "should load from couch representation" do
        couch = [ 'foo', 'def', 'baz' ]
        
        result = set_class(String).from_couch(couch)
        result.should be_an_instance_of(set_class(String))
        result.should == couch
      end
      
      it "should serialize to couch representation" do
        subject.concat(['abc', 'def', 'foo', '123'])
        subject.to_couch.should == ['abc', 'def', 'foo', '123']
      end
      
      it "should convert values to strings when assigning by index" do
        subject[0] = :foo
        subject[1] = 124
        subject.should == ['foo', '124']
      end
      
      it "should convert values to strings when adding" do
        (subject + [:foo, 124]).should == ['foo', '124']
      end
      
      it "should convert values to strings when appending" do
        subject << :foo
        subject << 124
        subject.should == ['foo', '124']
      end
      
      it "should convert values to strings when concatenating" do
        subject.concat([:foo, 124])
        subject.should == ['foo', '124']
      end
      
      it "should convert values to strings when deleting" do
        subject.concat(['abc', 'def', 'abc', 'foo', '123'])
        subject.delete(:abc)
        subject.delete(123)
        subject.should == ['def', 'foo']
      end
      
      it "should convert values to strings when getting index" do
        subject.concat(['abc', 'def', 'foo', '123'])
        subject.index(:abc).should == 0
        subject.index(123).should == 3
        subject.index('missing').should be_nil
      end
      
      it "should convert values to strings when getting rindex" do
        subject.concat(['abc', 'def', 'abc', 'foo', '123'])
        subject.rindex(:abc).should == 2
      end
      
      it "should convert values to strings when inserting" do
        subject.concat(['abc', 'def', 'foo', '123'])
        subject.insert(1, 999)
        subject.should == ['abc', '999', 'def', 'foo', '123']
      end
      
      it "should convert values to strings when pushing" do
        subject.push(:abc, 123, 'foo')
        subject.should == ['abc', '123', 'foo']
      end
      
      it "should convert values to strings when unshifting" do
        subject.unshift(:abc, 123, 'foo')
        subject.should == ['abc', '123', 'foo']
      end
      
      it "should inspect like an Array" do
        subject.concat(['abc', 'def', 'foo', '123'])
        subject.inspect.should == '["abc", "def", "foo", "123"]'
      end
    end
    
    context "with type Integer" do
      subject { set_class(Integer).new }
      
      it "should load from couch representation" do
        couch = [ 7, 0, 99 ]
        
        result = set_class(Integer).from_couch(couch)
        result.should be_an_instance_of(set_class(Integer))
        result.should == couch
      end
      
      it "should serialize to couch representation" do
        subject.concat([7, 0, 99, 14])
        subject.to_couch.should == [7, 0, 99, 14]
      end
      
      it "should convert values to integers when assigning by index" do
        subject[0] = '37'
        subject[1] = 124.5
        subject.should == [37, 124]
      end
      
      it "should convert values to integers when adding" do
        (subject + ['37', 124.5]).should == [37, 124]
      end
      
      it "should convert values to integers when appending" do
        subject << '37'
        subject << 124.5
        subject.should == [37, 124]
      end
      
      it "should convert values to integers when concatenating" do
        subject.concat(['37', 124.5])
        subject.should == [37, 124]
      end
      
      it "should convert values to integers when deleting" do
        subject.concat([99, 7, 0, 99, 14])
        subject.delete('99')
        subject.delete(7.5)
        subject.should == [0, 14]
      end
      
      it "should convert values to integers when getting index" do
        subject.concat([7, 0, 99, 14])
        subject.index('7').should == 0
        subject.index(99.5).should == 2
        subject.index(35).should be_nil
      end
      
      it "should convert values to integers when getting rindex" do
        subject.concat([99, 7, 0, 99, 14])
        subject.rindex(99.5).should == 3
      end
      
      it "should convert values to integers when inserting" do
        subject.concat([7, 0, 99, 14])
        subject.insert(1, 36.4)
        subject.should == [7, 36, 0, 99, 14]
      end
      
      it "should convert values to integers when pushing" do
        subject.push('35', 123.5, 99)
        subject.should == [35, 123, 99]
      end
      
      it "should convert values to integers when unshifting" do
        subject.unshift('35', 123.5, 99)
        subject.should == [35, 123, 99]
      end
      
      it "should inspect like an Array" do
        subject.concat([1, 2, 3, 4])
        subject.inspect.should == '[1, 2, 3, 4]'
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
