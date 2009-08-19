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
    
    shared_examples_for "saving a new record successfully" do
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
    
    shared_examples_for "saving an existing record successfully" do
      subject { TestDocument.new(:id => 'document-id') }
      
      before(:each) do
        save_with_stubbed_database(subject)
        @database.stub!(:put).and_return({ 'id' => 'document-id', 'rev' => '2-23456' })
      end
      
      it "should return true" do
        do_save.should be_true
      end
      
      it "should PUT the document to the database" do
        @database.should_receive(:put).
                  with('document-id', { 'class' => 'TestDocument', '_id' => 'document-id', '_rev' => '1-12345' }).
                  and_return({ 'id' => 'document-id', 'rev' => '2-23456' })
        
        do_save
      end
      
      context "after saving" do
        before(:each) { do_save }
        
        it { should_not be_a_new_record }
        
        it "should update the document revision" do
          subject.rev.should == '2-23456'
        end
      end
    end
    
    describe "#save" do
      def do_save; subject.save; end
      
      context "a new record" do
        it_should_behave_like "saving a new record successfully"
      end
      
      context "an existing record" do
        context "with the correct revision" do
          it_should_behave_like "saving an existing record successfully"
        end
        
        context "with an invalid revision" do
          subject { TestDocument.new(:id => 'document-id') }
          
          before(:each) do
            save_with_stubbed_database(subject)
            @database.stub!(:put).and_raise(Recliner::StaleRevisionError)
          end
          
          it "should return false" do
            do_save.should be_false
          end
        end
      end
    end
    
    describe "#save!" do
      def do_save; subject.save!; end
      
      context "a new record" do
        it_should_behave_like "saving a new record successfully"
      end
      
      context "an existing record" do
        context "with the correct revision" do
          it_should_behave_like "saving an existing record successfully"
        end
        
        context "with an invalid revision" do
          subject { TestDocument.new(:id => 'document-id') }
          
          before(:each) do
            save_with_stubbed_database(subject)
            @database.stub!(:put).and_raise(Recliner::StaleRevisionError)
          end
          
          it "should raise a DocumentNotSaved exception" do
            lambda { do_save }.should raise_error(Recliner::DocumentNotSaved)
          end
        end
      end
    end
  end
end
