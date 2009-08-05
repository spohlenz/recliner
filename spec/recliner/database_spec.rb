require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Recliner::Database" do
  before(:each) do
    @db = Recliner::Database.new('http://localhost:5984/recliner-test-alt')
  end
  
  it "should create the database if missing" do
    CouchDB.no_database_at('http://localhost:5984/recliner-test-alt')
    @db = Recliner::Database.new('http://localhost:5984/recliner-test-alt')
    
    CouchDB.should have_database('http://localhost:5984/recliner-test-alt')
  end
  
  it "should be accessable from a model" do
    DatabaseTestDocument.database.uri.should == 'http://localhost:5984/recliner-test'
  end
  
  it "should be overridable" do
    DatabaseTestDocument.use_database!('http://localhost:5984/recliner-test-alt')
    DatabaseTestDocument.database.uri.should == 'http://localhost:5984/recliner-test-alt'
  end
end

describe "Overriding the database for a Recliner::Document class" do
  before(:each) do
    @db = Recliner::Database.new('http://localhost:5984/recliner-test-alt')
  end
  
  it "should use the given database within the block" do
    DatabaseTestDocument.with_database(@db) do
      DatabaseTestDocument.database.should == @db
    end
  end
  
  it "should persist using the database after the block, for records created/loaded within the block" do
    CouchDB.no_document_at('http://localhost:5984/recliner-test-alt/test')
    
    DatabaseTestDocument.with_database(@db) do
      @doc = DatabaseTestDocument.new(:id => 'test')
    end
    
    @doc.save
    CouchDB.should have_document({}).at('http://localhost:5984/recliner-test-alt/test')
  end
end
