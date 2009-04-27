require File.dirname(__FILE__) + '/../spec_helper'

class BasicDocument < Recliner::Document; end

describe "A Recliner::Document class" do
  subject { BasicDocument }
  
  it "should have two default properties" do
    subject.properties.should have(2).keys
  end
end

describe "An instance of a Recliner::Document class" do
  subject { BasicDocument.new }
  
  it "should have an id" do
    subject.id.should_not be_nil
  end
  
  it "should be a new record" do
    subject.new_record?.should be_true
  end
end

describe "Save a Recliner::Document" do
  describe "a new document" do
    subject { BasicDocument.new(:id => 'abc') }
  
    before(:each) do
      CouchDB.no_document_at('http://localhost:5984/recliner-test/abc')
      subject.save
    end
  
    it "should not be a new record" do
      subject.new_record?.should be_false
    end
  
    it "should have a revision" do
      subject.rev.should_not be_nil
    end
  
    it "should save the document in the database" do
      CouchDB.should have_document({ :class => 'BasicDocument', :_id => 'abc' }).
                     at('http://localhost:5984/recliner-test/abc')
    end
  end
  
  describe "an existing document" do
    
  end
  
  describe "an existing document with an out-of-date revision" do
    
  end
end

describe "Load a Recliner::Document" do
  describe "an existing document" do
    subject { BasicDocument.load('abc') }
    
    before(:each) do
      CouchDB.document_at('http://localhost:5984/recliner-test/abc',
                          { :class => 'BasicDocument', :_id => 'abc' })
    end
    
    it { should be_an_instance_of(BasicDocument) }
    
    it "should have the correct id" do
      subject.id.should == 'abc'
    end
    
    it "should have a revision" do
      subject.rev.should_not be_nil
    end
    
    it "should not be a new record" do
      subject.new_record?.should be_false
    end
  end
  
  describe "a missing document" do
    before(:each) do
      CouchDB.no_document_at('http://localhost:5984/recliner-test/abc')
    end
    
    it "should raise a Recliner::DocumentNotFound exception" do
      lambda {
        BasicDocument.load('abc')
      }.should raise_error(Recliner::DocumentNotFound)
    end
  end
  
  describe "a document with the incorrect class" do
    before(:each) do
      CouchDB.document_at('http://localhost:5984/recliner-test/abc',
                          { :class => 'WrongDocument', :_id => 'abc' })
    end
    
    it "should raise a Recliner::DocumentNotFound exception" do
      lambda {
        BasicDocument.load('abc')
      }.should raise_error(Recliner::DocumentNotFound)
    end
  end
end
