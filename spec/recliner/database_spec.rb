require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Recliner
  describe Database do
    before(:each) do
      @db = Database.new('http://localhost:5984/my-database')
    end
    
    it "should set the database uri when instantiated" do
      @db.uri.should == 'http://localhost:5984/my-database'
    end
    
    it "should be equal to another database with the same URI" do
      @db.should == Database.new('http://localhost:5984/my-database')
    end
    
    it "should not be equal to another database with a different URI" do
      @db.should_not == Database.new('http://localhost:5984/another-database')
    end
    
    describe "#get" do
      it "should GET the database root" do
        Recliner.should_receive(:get).with('http://localhost:5984/my-database', {})
        @db.get
      end
      
      it "should GET a document" do
        Recliner.should_receive(:get).with('http://localhost:5984/my-database/document-id', { :arg => 'value' })
        @db.get('document-id', :arg => 'value')
      end
    end
    
    describe "#post" do
      it "should POST to the database root" do
        Recliner.should_receive(:post).with('http://localhost:5984/my-database', { :arg => 'value' }, {})
        @db.post(nil, :arg => 'value')
      end
      
      it "should POST to a document" do
        Recliner.should_receive(:post).with('http://localhost:5984/my-database/document-id', { :arg => 'value' }, {})
        @db.post('document-id', :arg => 'value')
      end
    end
    
    describe "#put" do
      it "should PUT to a document" do
        Recliner.should_receive(:put).with('http://localhost:5984/my-database/document-id', { :arg => 'value' }, {})
        @db.put('document-id', :arg => 'value')
      end
    end
    
    describe "#delete" do
      it "should not DELETE the database root" do
        Recliner.should_not_receive(:delete)
        @db.delete(nil)
      end
      
      it "should DELETE a document" do
        Recliner.should_receive(:delete).with('http://localhost:5984/my-database/document-id')
        @db.delete('document-id')
      end
    end
    
    describe "#delete!" do
      it "should DELETE the database" do
        Recliner.should_receive(:delete).with('http://localhost:5984/my-database')
        @db.delete!
      end
    end
    
    describe "#create!" do
      it "should PUT to the database root" do
        Recliner.should_receive(:put).with('http://localhost:5984/my-database')
        @db.create!
      end
    end
    
    describe "#recreate!" do
      context "database doesn't exist" do
        before(:each) do
          Recliner.stub!(:delete).and_raise(Recliner::DocumentNotFound)
          @db.stub!(:create!).and_return({ 'result' => 'ok' })
        end
        
        it "should try to delete the database" do
          @db.should_receive(:delete!).and_raise(Recliner::DocumentNotFound)
          @db.recreate!
        end
        
        it "should create the database" do
          @db.should_receive(:create!)
          @db.recreate!
        end
      end
      
      context "database exists" do
        before(:each) do
          @db.stub!(:delete!).and_return({ 'result' => 'ok' })
          @db.stub!(:create!).and_return({ 'result' => 'ok' })
        end
        
        it "should delete the database" do
          @db.should_receive(:delete!)
          @db.recreate!
        end
        
        it "should create the database" do
          @db.should_receive(:create!)
          @db.recreate!
        end
      end
    end
  end
end
