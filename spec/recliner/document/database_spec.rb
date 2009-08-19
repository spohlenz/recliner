require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    it "should have a default database URI" do
      Recliner::Document.database.uri.should == 'http://localhost:5984/recliner-default'
    end
    
    describe "setting a different database URI" do
      before(:each) do
        Recliner::Document.use_database! 'http://localhost:5984/recliner-default'
      end
      
      context "for all classes" do
        before(:each) do
          Recliner::Document.use_database! 'http://localhost:5984/recliner-alternate'
        end
        
        after(:each) do
          Recliner::Document.use_database! 'http://localhost:5984/recliner-default'
        end
      
        it "should change the parent database" do
          Recliner::Document.database.uri.should == 'http://localhost:5984/recliner-alternate'
        end
      
        it "should change the database used by new subclasses" do
          class NewTestDocument < Recliner::Document; end
          NewTestDocument.database.uri.should == 'http://localhost:5984/recliner-alternate'
        end
      end
    
      context "for subclasses" do
        before(:each) do
          TestDocument.use_database! 'http://localhost:5984/test-database'
        end
      
        it "should change the database for the subclass" do
          TestDocument.database.uri.should == 'http://localhost:5984/test-database'
        end
      
        it "should not change the parent database" do
          Recliner::Document.database.uri.should == 'http://localhost:5984/recliner-default'
        end
      end
    end
    
    context "within an instance" do
      it "should use the same database as the class" do
        TestDocument.new.database.should == TestDocument.database
      end
    end
  end
end
