require File.dirname(__FILE__) + '/../spec_helper'

describe "RESTful CouchDB access" do
  describe "GET an existing document" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.document_at(@uri, { "foo" => "bar", "abc" => 1 })
    end
    
    it "should return a hash of the document" do
      Recliner.get(@uri).should contain_hash({ 'foo' => 'bar', 'abc' => 1 })
    end
  end
  
  describe "GET a nonexistant document" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.no_document_at(@uri)
    end
    
    it "should raise a Recliner::DocumentNotFound exception" do
      lambda {
        Recliner.get(@uri)
      }.should raise_error(Recliner::DocumentNotFound)
    end
  end
  
  describe "POST a new document" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test'
      @result = Recliner.post(@uri, { :foo => 'bar', :abc => 1 })
    end
    
    it "should return a result hash" do
      @result['id'].should_not be_nil
      @result['rev'].should_not be_nil
    end
    
    it "should create the document" do
      CouchDB.should have_document({ :foo => 'bar', :abc => 1 }).at("#{@uri}/#{@result['id']}")
    end
  end
  
  describe "PUT a new document" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.no_document_at(@uri)
      @result = Recliner.put(@uri, { :foo => 'bar', :abc => 1 })
    end
    
    it "should return a result hash" do
      @result['id'].should == 'abc'
      @result['rev'].should_not be_nil
    end
    
    it "should create the document" do
      CouchDB.should have_document({ :foo => 'bar', :abc => 1 }).at(@uri)
    end
  end
  
  describe "PUT to an existing document (with current revision)" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.document_at(@uri, { "foo" => "bar", "abc" => 1 })
      @rev = CouchDB.revision_for_document(@uri)
      @result = Recliner.put(@uri, { :foo => 'baz', :abc => 2, :_rev => @rev })
    end
    
    it "should return a result hash" do
      @result['id'].should == 'abc'
      @result['rev'].should_not be_nil
    end
    
    it "should update the document" do
      CouchDB.should have_document({ :foo => 'baz', :abc => 2 }).at(@uri)
    end
  end
  
  describe "PUT to an existing document with an out-of-date revision" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.document_at(@uri, { "foo" => "bar", "abc" => 1 })
    end
    
    it "should raise a Recliner::StaleRevisionError exception" do
      lambda {
        Recliner.put(@uri, { :foo => 'baz', :abc => 2, :_rev => 'WRONG' })
      }.should raise_error(Recliner::StaleRevisionError)
    end
  end
  
  describe "DELETE an existing document" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.document_at(@uri, { "foo" => "bar", "abc" => 1 })
      @rev = CouchDB.revision_for_document(@uri)
      Recliner.delete("#{@uri}?rev=#{@rev}")
    end
    
    it "should delete the document" do
      CouchDB.should_not have_document.at(@uri)
    end
  end
  
  describe "DELETE an existing document with an out-of-date revision" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.document_at(@uri, { "foo" => "bar", "abc" => 1 })
    end
    
    it "should raise a Recliner::StaleRevisionError exception" do
      lambda {
        Recliner.delete("#{@uri}?rev=WRONG")
      }.should raise_error(Recliner::StaleRevisionError)
    end
  end
  
  describe "DELETE a non-existent document" do
    before(:each) do
      @uri = 'http://localhost:5984/recliner-test/abc'
      CouchDB.no_document_at(@uri)
    end
    
    it "should raise a Recliner::DocumentNotFound exception if it doesn't exist" do
      lambda {
        Recliner.delete(@uri)
      }.should raise_error(Recliner::DocumentNotFound)
    end
  end
end
