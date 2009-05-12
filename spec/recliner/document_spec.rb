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
  
  it "should allow attributes to be assigned with a hash" do
    subject.attributes = { :id => '123', :rev => '456' }
    subject.id.should == '123'
    subject.rev.should == '456'
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
  
  describe "an existing document (changing id)" do
    subject { BasicDocument.load('abc') }
    
    before(:each) do
      CouchDB.no_document_at('http://localhost:5984/recliner-test/1234')
      CouchDB.document_at('http://localhost:5984/recliner-test/abc',
                          { :class => 'BasicDocument', :_id => 'abc' })
      
      subject.id = '1234'
    end
    
    it "should save the document" do
      subject.save.should be_true
    end
    
    it "should remove the document at the old id" do
      subject.save
      CouchDB.should_not have_document.at('http://localhost:5984/recliner-test/abc')
    end
    
    it "should create the document at the new id" do
      subject.save
      CouchDB.should have_document({ :class => 'BasicDocument', :_id => '1234' }).
                     at('http://localhost:5984/recliner-test/1234')
    end
  end
  
  describe "an existing document with an out-of-date revision" do
    subject { BasicDocument.load('abc') }
    
    before(:each) do
      CouchDB.document_at('http://localhost:5984/recliner-test/abc',
                          { :class => 'BasicDocument', :_id => 'abc' })
      subject.rev = 'WRONG'
    end
    
    it "should not save the document" do
      subject.save.should be_false
    end
    
    it "should raise a Recliner::StaleRevisionError error when using save!" do
      lambda {
        subject.save!
      }.should raise_error(Recliner::StaleRevisionError)
    end
  end
  
  describe "an invalid document" do
    subject { BasicDocument.new }
    
    before(:each) do
      subject.stub!(:valid?).and_return(false)
    end
    
    it "should not save" do
      subject.save.should be_false
    end
    
    it "should raise a Recliner::DocumentNotSaved error when using save!" do
      lambda {
        subject.save!
      }.should raise_error(Recliner::DocumentNotSaved)
    end
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
  
  describe "loading via Recliner::Document" do
    before(:each) do
      CouchDB.document_at('http://localhost:5984/recliner-test/abc',
                          { :class => 'BasicDocument', :_id => 'abc' })
    end
    
    it "should return the same object as BasicDocument.load" do
      Recliner::Document.load('abc').should == BasicDocument.load('abc')
    end
  end
end


describe "Loading multiple Recliner::Documents" do
  it "should return documents given multiple doc ids" do
    CouchDB.document_at('http://localhost:5984/recliner-test/first', { :class => 'BasicDocument' })
    CouchDB.document_at('http://localhost:5984/recliner-test/second', { :class => 'BasicDocument' })
    CouchDB.document_at('http://localhost:5984/recliner-test/third', { :class => 'BasicDocument' })
    
    result = BasicDocument.load('first', 'second', 'third')
    result.map(&:id).should == [ 'first', 'second', 'third' ]
  end
  
  it "should raise Recliner::DocumentNotFound if any document id doesn't exist" do
    CouchDB.document_at('http://localhost:5984/recliner-test/first', { :class => 'BasicDocument' })
    CouchDB.document_at('http://localhost:5984/recliner-test/second', { :class => 'BasicDocument' })
    CouchDB.no_document_at('http://localhost:5984/recliner-test/third')
    
    lambda {
      BasicDocument.load('first', 'second', 'third')
    }.should raise_error(Recliner::DocumentNotFound)
  end
  
  it "should raise Recliner::DocumentNotFound if any document has an incorrect class" do
    CouchDB.document_at('http://localhost:5984/recliner-test/first', { :class => 'BasicDocument' })
    CouchDB.document_at('http://localhost:5984/recliner-test/second', { :class => 'BasicDocument' })
    CouchDB.document_at('http://localhost:5984/recliner-test/third', { :class => 'WrongDocument' })
    
    lambda {
      BasicDocument.load('first', 'second', 'third')
    }.should raise_error(Recliner::DocumentNotFound)
  end
end


module ReclinerTest
  class TestClass < Recliner::Document; end
end  

describe "Save a scoped Recliner::Document" do
  subject { ReclinerTest::TestClass.new(:id => '1234') }
  
  before(:each) do
    CouchDB.no_document_at('http://localhost:5984/recliner-test/1234')
    subject.save
  end
  
  it "should set the class attribute correctly" do
    CouchDB.should have_document({ :class => 'ReclinerTest::TestClass' }).
                   at('http://localhost:5984/recliner-test/1234')
  end
end
