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
    
    KeyExamples = {
      String => {
        :before_type_cast => { 'string' => 'string value', :symbol => 'symbol value', 123 => 'int value', 45.5 => 'float value' },
        :after_type_cast => { 'string' => 'string value', 'symbol' => 'symbol value', '123' => 'int value', '45.5' => 'float value' },
        :couch => { 'string' => 'string value', 'symbol' => 'symbol value', '123' => 'int value', '45.5' => 'float value' }
      },
        
      Integer => {
        :before_type_cast => { 123 => 'int value', '88' => 'string value', '94.5' => 'string float value', 0.123 => 'float value' },
        :after_type_cast => { 123 => 'int value', 88 => 'string value', 94 => 'string float value', 0 => 'float value' },
        :couch => { '123' => 'int value', '88' => 'string value', '94' => 'string float value', '0' => 'float value' }
      }
    }
    
    KeyExamples.each do |type, conversions|
      couch = conversions[:couch]
      before_type_cast = conversions[:before_type_cast]
      after_type_cast = conversions[:after_type_cast]
      
      context "keyed by #{type}" do
        subject { map_class(type, String) }
        
        it "should load from couch representation" do
          result = subject.from_couch(couch)
          result.should be_an_instance_of(subject)
          result.should == after_type_cast
        end
        
        it "should serialize to couch representation" do
          map = subject[after_type_cast]
          map.to_couch.should == couch
        end
        
        it "should convert keys when creating from hash" do
          map = subject[before_type_cast]
          map.should be_an_instance_of(subject)
          map.should == after_type_cast
        end
        
        it "should convert keys when assigned using []=" do
          map = subject.new
          before_type_cast.each do |key, value|
            map[key] = value
          end
          map.should == after_type_cast
        end
        
        it "should convert keys when assigned using store" do
          map = subject.new
          before_type_cast.each do |key, value|
            map.store(key, value)
          end
          map.should == after_type_cast
        end
        
        it "should convert keys when fetched using []" do
          map = subject[after_type_cast]
          before_type_cast.each do |key, value|
            map[key].should == value
          end
        end
        
        it "should convert keys when fetched using fetch" do
          map = subject[after_type_cast]
          before_type_cast.each do |key, value|
            map.fetch(key).should == value
          end
        end
        
        [ :has_key?, :include?, :key?, :member? ].each do |query_method|
          it "should convert keys when queried using #{query_method}" do
            map = subject[after_type_cast]
            before_type_cast.keys.each do |key, value|
              map.send(query_method, key).should be_true
            end
          end
        end
        
        it "should convert keys when updating" do
          map = subject.new
          map.update(before_type_cast)
          map.should == after_type_cast
        end
        
        it "should convert keys when replacing" do
          map = subject.new
          map.replace(before_type_cast)
          map.should == after_type_cast
        end
        
        it "should duplicate to another Map with the same mapping" do
          map = subject[after_type_cast]
          
          copy = map.dup
          copy.should be_an_instance_of(subject)
          copy.should == after_type_cast
        end
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
        lambda { map['foo'] = 'wrong type' }.should raise_error(TypeError)
      end
    end
    
    
    MapExamples = {
      String => {
        :before_type_cast => { 'string' => 'string value', 'integer' => 99, 'float' => 10.55, 'nil' => nil },
        :after_type_cast => { 'string' => 'string value', 'integer' => '99', 'float' => '10.55', 'nil' => nil },
        :couch => { 'string' => 'string value', 'integer' => '99', 'float' => '10.55', 'nil' => nil }
      },
      
      Integer => {
        :before_type_cast => { 'string' => '99', 'float' => 45.5, 'string float' => '12.45', 'integer' => 123, 'nil' => nil },
        :after_type_cast => { 'string' => 99, 'float' => 45, 'string float' => 12, 'integer' => 123, 'nil' => nil },
        :couch => { 'string' => 99, 'float' => 45, 'string float' => 12, 'integer' => 123, 'nil' => nil },
      },
      
      Float => {
        :before_type_cast => { 'string' => '99.123', 'float' => 45.5, 'integer' => 123, 'nil' => nil },
        :after_type_cast => { 'string' => 99.123, 'float' => 45.5, 'integer' => 123, 'nil' => nil },
        :couch => { 'string' => 99.123, 'float' => 45.5, 'integer' => 123, 'nil' => nil },
      }
    }
    
    MapExamples.each do |type, conversions|
      couch = conversions[:couch]
      before_type_cast = conversions[:before_type_cast]
      after_type_cast = conversions[:after_type_cast]
      
      context "mapping to #{type}" do
        subject { map_class(String, type) }
        
        it "should load from couch representation" do
          result = subject.from_couch(couch)
          result.should be_an_instance_of(subject)
          result.should == after_type_cast
        end
        
        it "should serialize to couch representation" do
          map = subject[after_type_cast]
          map.to_couch.should == couch
        end
        
        it "should convert values when assigning using []=" do
          map = subject.new
          before_type_cast.each do |key, value|
            map[key] = value
          end
          map.should == after_type_cast
        end
        
        it "should convert values when assigning using store" do
          map = subject.new
          before_type_cast.each do |key, value|
            map.store(key, value)
          end
          map.should == after_type_cast
        end
        
        it "should convert values when updating" do
          map = subject.new
          map.update(before_type_cast)
          map.should == after_type_cast
        end
        
        it "should convert values when replacing" do
          map = subject.new
          map.replace(before_type_cast)
          map.should == after_type_cast
        end
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
        lambda { map['foo'] = 'wrong type' }.should raise_error(TypeError)
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
