require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  module MapClassHelper
    def map_class(from, to)
      map_classes[[from, to]] ||= begin
        klass = Class.new(Map)
        klass.from = from
        klass.to = to
        klass
      end
    end
    
    def map_classes
      @map_classes ||= {}
    end
  end
  
  describe Map do
    include MapClassHelper
    
    describe "class" do
      it "should be equal to another Map class with the same mapping" do
        map_class(String, Integer).should == map_class(String, Integer)
        map_class(Date, String).should == map_class(Date, String)
      end
    
      it "should not be equal to another Map class with a different mapping" do
        map_class(String, Integer).should_not == map_class(String, Date)
        map_class(Integer, Integer).should_not == map_class(Date, String)
      end
      
      it "should show the mapping types when inspected" do
        map_class(String, Integer).inspect.should == "#<Map[String -> Integer]>"
        map_class(Date, Integer).inspect.should == "#<Map[Date -> Integer]>"
        map_class(Date, String).inspect.should == "#<Map[Date -> String]>"
      end
    end
    
    
    context "keyed by String" do
      subject { map_class(String, String) }
      
      it "should load from couch representation" do
        couch    = { 'Foo' => '12345', 'Abc' => 'abcde' }
        expected = { 'Foo' => '12345', 'Abc' => 'abcde' }
        
        result = subject.from_couch(couch)
        result.should be_an_instance_of(subject)
        result.should == expected
      end
      
      it "should convert keys to strings when assigned using []=" do
        map = subject.new
        map['str'] = 'assigned str'
        map[:foo] = 'assigned foo'
        map[123] = 'assigned 123'
        
        map.should == { 'str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123' }
      end
      
      it "should convert keys to strings when assigned using store" do
        map = subject.new
        map.store('str', 'assigned str')
        map.store(:foo, 'assigned foo')
        map.store(123, 'assigned 123')
        
        map.should == { 'str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123' }
      end
      
      it "should convert keys to strings when fetched using []" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123']
        
        map['str'].should == 'assigned str'
        map[:foo].should == 'assigned foo'
        map[123].should == 'assigned 123'
      end
      
      it "should convert keys to strings when fetched using fetch" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123']
        
        map.fetch('str').should == 'assigned str'
        map.fetch(:foo).should == 'assigned foo'
        map.fetch(123).should == 'assigned 123'
      end
      
      it "should convert keys to strings when queried" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123']
        
        [ :has_key?, :include?, :key?, :member? ].each do |query_method|
          map.send(query_method, 'str').should be_true
          map.send(query_method, :foo).should be_true
          map.send(query_method, 123).should be_true
          
          map.send(query_method, 'strabc').should be_false
          map.send(query_method, :baz).should be_false
          map.send(query_method, 99).should be_false
        end
      end
      
      it "should convert keys to strings when updating" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo']
        map.update(:foo => 'changed foo', 123 => 'assigned 123')
        
        map.should == { 'str' => 'assigned str', 'foo' => 'changed foo', '123' => 'assigned 123' }
      end
      
      it "should convert keys to strings when replacing" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo']
        map.replace(:foo => 'new foo', 123 => 'assigned 123', 'string' => 'the string')
        
        map.should == { 'string' => 'the string', 'foo' => 'new foo', '123' => 'assigned 123' }
      end
      
      it "should inspect like a hash" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123']
        map.inspect.should == '{"str"=>"assigned str", "foo"=>"assigned foo", "123"=>"assigned 123"}'
      end
      
      it "should duplicate to another Map with the same mapping" do
        map = subject['str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123']
        
        copy = map.dup
        copy.should be_an_instance_of(subject)
        copy.should == { 'str' => 'assigned str', 'foo' => 'assigned foo', '123' => 'assigned 123' }
      end
    end
    
    context "keyed by Integer" do
      subject { map_class(Integer, String) }
      
      it "should load from couch representation" do
        couch    = { '12' => '12345', '99' => 'abcde' }
        expected = { 12 => '12345', 99 => 'abcde'}
        
        result = subject.from_couch(couch)
        result.should be_an_instance_of(subject)
        result.should == expected
      end
      
      it "should convert keys to integers when assigned using []=" do
        map = subject.new
        map['99'] = 'assigned str'
        map[123] = 'assigned 123'
        map[0.5] = 'assigned 0.5'
        
        map.should == { 0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123' }
      end
      
      it "should convert keys to integers when assigned using store" do
        map = subject.new
        map.store('99', 'assigned str')
        map.store(123, 'assigned 123')
        map.store(0.5, 'assigned 0.5')
        
        map.should == { 0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123' }
      end
      
      it "should convert keys to integers when fetched using []" do
        map = subject[0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123']
        
        map[0.5].should == 'assigned 0.5'
        map['99'].should == 'assigned str'
        map[123].should == 'assigned 123'
      end
      
      it "should convert keys to integers when fetched using fetch" do
        map = subject[0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123']
        
        map.fetch(0.5).should == 'assigned 0.5'
        map.fetch('99').should == 'assigned str'
        map.fetch(123).should == 'assigned 123'
      end
      
      it "should convert keys to integers when queried" do
        map = subject[0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123']
        
        [ :has_key?, :include?, :key?, :member? ].each do |query_method|
          map.send(query_method, 0.5).should be_true
          map.send(query_method, '99').should be_true
          map.send(query_method, 123).should be_true
          
          map.send(query_method, '1.2').should be_false
          map.send(query_method, '50').should be_false
          map.send(query_method, 999).should be_false
        end
      end
      
      it "should convert keys to integers when updating" do
        map = subject[123 => 'assigned 123', 99 => 'assigned str']
        map.update('99' => 'updated str', 0.5 => 'assigned 0.5')
        
        map.should == { 0 => 'assigned 0.5', 99 => 'updated str', 123 => 'assigned 123' }
      end
      
      it "should convert keys to integers when replacing" do
        map = subject[123 => 'assigned 123', 99 => 'assigned str']
        map.replace('99' => 'updated str', 0.5 => 'assigned 0.5')
        
        map.should == { 0 => 'assigned 0.5', 99 => 'updated str' }
      end
      
      it "should inspect like a hash" do
        map = subject[0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123']
        map.inspect.should == '{0=>"assigned 0.5", 99=>"assigned str", 123=>"assigned 123"}'
      end
      
      it "should duplicate to another Map with the same mapping" do
        map = subject[0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123']
        
        copy = map.dup
        copy.should be_an_instance_of(subject)
        copy.should == { 0 => 'assigned 0.5', 99 => 'assigned str', 123 => 'assigned 123' }
      end
    end
    
    context "keyed by a custom class" do
      # The couch serialization of the custom class must be a
      # plain old string, as JSON keys can only be strings
      
      class ::CustomKeyClass
        attr_reader :name
        
        def initialize(name)
          @name = name
        end
        
        def to_s
          name
        end
        
        def self.from_couch(str)
          new(str)
        end
        
        def eql?(other)
          name.eql?(other.name)
        end
        
        def hash
          name.hash
        end
      end
      
      subject { map_class(CustomKeyClass, String) }
      
      it "should convert keys to custom class instances when loading from couch" do
        couch    = { 'abc' => 'string for abc', 'def' => 'string for def' }
        expected = { CustomKeyClass.new('abc') => 'string for abc', CustomKeyClass.new('def') => 'string for def' }
        
        result = subject.from_couch(couch)
        result.should be_an_instance_of(subject)
        result.should == expected
      end
      
      it "should convert keys to strings when serializing to couch" do
        map = subject.new
        map[CustomKeyClass.new('abc')] = 'string for abc'
        map[CustomKeyClass.new('def')] = 'string for def'
        
        map.to_couch.should == { 'abc' => 'string for abc', 'def' => 'string for def' }
      end
      
      it "should raise a TypeError if an assigned key is not a custom class" do
        map = subject.new
        lambda { map['foo'] = 'wrong type' }.should raise_error(TypeError, 'expected CustomKeyClass but got String')
      end
    end
    
    
    context "mapping to String" do
      subject { map_class(String, String) }
      
      it "should convert values to strings when assigning using []=" do
        map = subject.new
        map['abc'] = 'string'
        map['foo'] = 99
        map['bar'] = 10.5
        
        map.should == { 'abc' => 'string', 'foo' => '99', 'bar' => '10.5' }
      end
      
      it "should convert values to strings when assigning using store" do
        map = subject.new
        map.store('abc', 'string')
        map.store('foo', 99)
        map.store('bar', 10.5)
        
        map.should == { 'abc' => 'string', 'foo' => '99', 'bar' => '10.5' }
      end
      
      it "should convert values to strings when updating" do
        map = subject['abc' => 'assigned abc', 'foo' => 'assigned foo']
        map.update('foo' => 99, 'bar' => 10.5)
        
        map.should == { 'abc' => 'assigned abc', 'foo' => '99', 'bar' => '10.5' }
      end
      
      it "should convert values to strings when replacing" do
        map = subject['abc' => 'assigned abc', 'foo' => 'assigned foo']
        map.replace('foo' => 99, 'bar' => 10.5)
        
        map.should == { 'foo' => '99', 'bar' => '10.5' }
      end
    end
    
    context "mapping to custom class" do
      # Unlike custom classes as Map _keys_, Map values may have
      # any valid couch serialization (e.g. Hash, Array, etc)
      
      class ::CustomValueClass
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
        
        def eql?(other)
          name.eql?(other.name)
        end
        
        def hash
          name.hash
        end
      end
      
      subject { map_class(String, CustomValueClass) }
      
      it "should convert values to custom class instances when loading from couch" do
        couch    = { 'abc' => { 'name' => 'abc' }, 'def' => { 'name' => 'def' } }
        expected = { 'abc' => CustomValueClass.new('abc'), 'def' => CustomValueClass.new('def') }
        
        result = subject.from_couch(couch)
        result.should be_an_instance_of(subject)
        result.should == expected
      end
      
      it "should convert values to couch representation when serializing to couch" do
        map = subject.new
        map['foo'] = CustomValueClass.new('foo')
        map['bar'] = CustomValueClass.new('bar')
        
        map.to_couch.should == { 'foo' => { 'name' => 'foo' }, 'bar' => { 'name' => 'bar' } }
      end
      
      it "should raise a TypeError if an assigned value is not a custom class" do
        map = subject.new
        lambda { map['foo'] = 'wrong type' }.should raise_error(TypeError, 'expected CustomValueClass but got String')
      end
    end
  end
  
  describe Property do
    include MapClassHelper
    
    describe "with type Map" do
      context "with no default value" do
        subject { Property.new(:map, map_class(String, Integer), :map, nil) }
        
        it "should default to a Map of the same type" do
          subject.default_value(nil).should be_an_instance_of(map_class(String, Integer))
        end
      end
      
      context "with a default value" do
        subject { Property.new(:map, map_class(String, String), :map, { :foo => 'bar' }) }
        
        it "should default to a Map of the same type" do
          subject.default_value(nil).should be_an_instance_of(map_class(String, String))
        end
        
        it "should default to a Map built from the given default" do
          subject.default_value(nil)['foo'].should == 'bar'
        end
      end
    end
  end
  
  describe Document do
    describe "#Map" do
      subject { Document.Map(String => Integer) }
      
      it "should return a new subclass of Recliner::Map" do
        subject.new.should be_a_kind_of(Recliner::Map)
      end
      
      it "should set the from type of the subclass" do
        subject.from.should == String
      end
      
      it "should set the to type of the subclass" do
        subject.to.should == Integer
      end
      
      it "should cache classes" do
        subject.should eql(Document.Map(String => Integer))
      end
      
      it "should raise an ArgumentError if no mappings given" do
        lambda {
          Document.Map({})
        }.should raise_error(ArgumentError, 'Exactly one type mapping must be given')
      end
      
      it "should raise an ArgumentError if more than one mapping given" do
        lambda {
          Document.Map(String => Integer, Integer => Float)
        }.should raise_error(ArgumentError, 'Exactly one type mapping must be given')
      end
    end
    
    describe "with a Map property" do
      context "with no default value" do
        define_recliner_document :TestDocument do
          property :map_property, Map(String => String)
        end
        
        subject { TestDocument.new }
        
        it "should default to an empty Map" do
          subject.map_property.should == {}
        end
      end
    end
  end
end
