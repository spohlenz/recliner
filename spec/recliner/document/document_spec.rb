require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    before(:each) do
      TestDocument.use_database! 'http://localhost:5984/recliner-test'
    end
    
    it "should be instantiable with no arguments" do
      TestDocument.new
    end
    
    it "should be instantiable with an attributes hash" do
      TestDocument.new(:id => 'my-custom-id')
    end
    
    it "should be instantiable with a block yielding itself" do
      yielded = nil
      result = TestDocument.new do |doc|
        yielded = doc
      end
      yielded.should == result
    end
    
    shared_examples_for "a newly instantiated document" do
      it { should be_a_new_record }
      
      it "should not have a revision" do
        subject.rev.should be_nil
      end
    end
    
    context "when instantiated without attributes" do
      subject { TestDocument.new }
      it_should_behave_like "a newly instantiated document"
      
      it "should autogenerate an id" do
        subject.id.should =~ /[0-9a-f-]{36}/
      end
    end
    
    context "when instantiated with attributes containing an id" do
      subject { TestDocument.new(:id => 'my-custom-id') }
      it_should_behave_like "a newly instantiated document"
      
      it "should use the given id" do
        subject.id.should == 'my-custom-id'
      end
    end
    
    describe "equality" do
      define_recliner_document :FirstType
      define_recliner_document :SecondType
      
      it "should be equal to another document of the same class with the same id" do
        FirstType.new(:id => 'abc').should == FirstType.new(:id => 'abc')
      end
      
      it "should not be equal to another document of the same class with a different id" do
        FirstType.new(:id => 'abc').should_not == FirstType.new(:id => '123')
      end
      
      it "should not be equal to another document of a different class with the same id" do
        FirstType.new(:id => 'abc').should_not == SecondType.new(:id => 'abc')
      end
      
      it "should not be equal to another document of a different class with a different id" do
        FirstType.new(:id => 'abc').should_not == SecondType.new(:id => '123')
      end
    end
    
    describe "#to_couch" do
      context "a model with no properties" do
        subject { TestDocument.new(:id => 'abc-123') }
        
        it "should return a hash containing the document class and id" do
          subject.to_couch.should == { 'class' => 'TestDocument', '_id' => 'abc-123' }
        end
      end
      
      context "a model with properties" do
        define_recliner_document :TestDocument do
          property :name, String
          property :age, Integer
        end
        
        subject { TestDocument.new(:id => 'abc-123', :name => 'My name', :age => 21 )}
        
        it "should return a hash containing the document class and the model attributes (excluding the id and rev)" do
          subject.to_couch.should == {
            'class' => 'TestDocument',
            '_id' => 'abc-123',
            'name' => 'My name',
            'age' => 21
          }
        end
      end
    end
    
    shared_examples_for "saving succesfully" do
      subject { TestDocument.new(:id => 'document-id') }
      
      before(:each) do
        @database = mock('database', :put => { 'id' => 'document-id', 'rev' => '1-12345' })
        subject.stub!(:database).and_return(@database)
      end
      
      it "should return true" do
        do_save.should be_true
      end
      
      it "should PUT the document to the database" do
        @database.should_receive(:put).
                  with('document-id', { 'class' => 'TestDocument', '_id' => 'document-id' }).
                  and_return({ 'id' => 'document-id', 'rev' => '1-12345' })
        
        do_save
      end
      
      context "after saving" do
        before(:each) { do_save }
        
        it { should_not be_a_new_record }
        
        it "should set the document revision" do
          subject.rev.should == '1-12345'
        end
      end
    end
    
    describe "#save" do
      def do_save; subject.save; end
      
      it_should_behave_like "saving succesfully"
    end
    
    describe "#save!" do
      def do_save; subject.save!; end
      
      it_should_behave_like "saving succesfully"
    end
  end
end
