require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document, '#inspect' do
    context "on base class" do
      it "should return class name" do
        Recliner::Document.inspect.should == 'Recliner::Document'
      end
    end
    
    context "on subclasses" do
      context "without properties" do
        define_recliner_document :TestDocument
      
        it "should return class name" do
          TestDocument.inspect.should == 'TestDocument()'
        end
      end
      
      context "with properties" do
        define_recliner_document :TestDocument do
          property :name, String
          property :age, Integer
        end
        
        it "should return class name and property definitions" do
          TestDocument.inspect.should == 'TestDocument(name: String, age: Integer)'
        end
      end
    end
    
    context "on subclass instances" do
      define_recliner_document :TestDocument do
        property :name, String
        property :age, Integer
      end
      
      context "with revision" do
        subject { TestDocument.new(:id => 'abc-123', :rev => '1-12345', :name => 'Doc name', :age => 54) }
      
        it "should return class name and property values" do
          subject.inspect.should == '#<TestDocument id: abc-123, rev: 1-12345, name: "Doc name", age: 54>'
        end
      end
      
      context "without revision" do
        subject { TestDocument.new(:id => 'abc-123', :name => 'Doc name', :age => 54) }
      
        it "should return class name and property values" do
          subject.inspect.should == '#<TestDocument id: abc-123, name: "Doc name", age: 54>'
        end
      end
    end
  end
end
