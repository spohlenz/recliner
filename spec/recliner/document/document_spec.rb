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
    
    shared_examples_for "loading a document successfully" do
      before(:each) do
        TestDocument.database.stub!(:get).and_return({
          'class' => 'TestDocument',
          '_id' => 'document-id',
          '_rev' => '1-12345',
          'name' => 'Document Name'
        })
      end
      
      it "should perform a GET on the database" do
        TestDocument.database.should_receive(:get).with('document-id').and_return({
          'class' => 'TestDocument',
          '_id' => 'document-id',
          '_rev' => '1-12345',
          'name' => 'Document Name'
        })
        do_load
      end
      
      it "should return a TestDocument instance with properties set" do
        doc = do_load
        
        doc.should be_an_instance_of(TestDocument)
        doc.id.should == 'document-id'
        doc.rev.should == '1-12345'
        doc.name.should == 'Document Name'
      end
      
      it "should not be a new record" do
        do_load.should_not be_a_new_record
      end
    end
    
    shared_examples_for "loading multiple documents successfully" do
      before(:each) do
        @result = {
          'total_rows' => 3,
          'offset' => 0,
          'rows' => [
            { 'id' => 'document-1', 'key' => 'document-1', 'doc' => { 'class' => 'TestDocument', '_id' => 'document-1', '_rev' => '1-12345', 'name' => 'First Document' } },
            { 'id' => 'document-2', 'key' => 'document-2', 'doc' => { 'class' => 'TestDocument', '_id' => 'document-2', '_rev' => '1-12345', 'name' => 'Second Document' } },
            { 'id' => 'document-3', 'key' => 'document-3', 'doc' => { 'class' => 'TestDocument', '_id' => 'document-3', '_rev' => '1-12345', 'name' => 'Third Document' } }
          ]
        }
        
        TestDocument.database.stub!(:post).and_return(@result)
      end
      
      it "should POST to _all_docs" do
        TestDocument.database.should_receive(:post).
                              with('_all_docs', { :keys => ['document-1', 'document-2', 'document-3'] }, { :include_docs => true }).
                              and_return(@result)
        do_load
      end
      
      it "should return instances of each document with properties set" do
        result = do_load
        
        result[0].id.should == 'document-1'
        result[1].id.should == 'document-2'
        result[2].id.should == 'document-3'
        
        result[0].name.should == 'First Document'
        result[1].name.should == 'Second Document'
        result[2].name.should == 'Third Document'
      end
      
      specify "each document should not be a new record" do
        do_load.each { |doc| doc.should_not be_a_new_record }
      end
    end
    
    describe "#load" do
      define_recliner_document :TestDocument do
        property :name, String
      end
      
      context "an individual document" do
        def do_load
          TestDocument.load('document-id')
        end
        
        context "document exists" do
          it_should_behave_like "loading a document successfully"
        end
        
        shared_examples_for "document does not exist (for #load)" do
          it "should return nil" do
            do_load.should be_nil
          end
        end
        
        context "document does not exist" do
          before(:each) do
            TestDocument.database.stub!(:get).and_raise(Recliner::DocumentNotFound)
          end
          
          it_should_behave_like "document does not exist (for #load)"
        end
        
        context "document has incorrect class" do
          before(:each) do
            TestDocument.database.stub!(:get).and_return({
              'class' => 'WrongClass',
              '_id' => 'document-id',
              '_rev' => '1-12345'
            })
          end
          
          it_should_behave_like "document does not exist (for #load)"
        end
      end
      
      context "multiple documents" do
        def do_load
          TestDocument.load('document-1', 'document-2', 'document-3')
        end
        
        context "all documents exist" do
          it_should_behave_like "loading multiple documents successfully"
        end
        
        context "some documents do not exist or have incorrect class" do
          before(:each) do
            @result = {
              'total_rows' => 3,
              'offset' => 0,
              'rows' => [
                { 'id' => 'document-1', 'key' => 'document-1', 'doc' => { 'class' => 'TestDocument', '_id' => 'document-1', '_rev' => '1-12345', 'name' => 'First Document' } },
                { 'error' => 'not_found', 'key' => 'document-2' },
                { 'id' => 'document-3', 'key' => 'document-3', 'doc' => { 'class' => 'WrongClass', '_id' => 'document-3', '_rev' => '1-12345' } }
              ]
            }

            TestDocument.database.stub!(:post).and_return(@result)
          end
          
          it "should return an array containing the existing documents and nil values" do
            result = do_load
            
            doc = result[0]
            doc.should be_an_instance_of(TestDocument)
            doc.id.should == 'document-1'
            doc.rev.should == '1-12345'
            doc.name.should == 'First Document'
            doc.should_not be_a_new_record
            
            result[1].should be_nil
            result[2].should be_nil
          end
        end
      end
    end
    
    describe "#load!" do
      define_recliner_document :TestDocument do
        property :name, String
      end
      
      context "an individual document" do
        def do_load
          TestDocument.load!('document-id')
        end
        
        context "document exists" do
          it_should_behave_like "loading a document successfully"
        end
        
        shared_examples_for "document does not exist (for #load!)" do
          it "should raise a Recliner::DocumentNotFound exception" do
            lambda { do_load }.should raise_error(Recliner::DocumentNotFound)
          end
        end
        
        context "document does not exist" do
          before(:each) do
            TestDocument.database.stub!(:get).and_raise(Recliner::DocumentNotFound)
          end
          
          it_should_behave_like "document does not exist (for #load!)"
        end
        
        context "document has incorrect class" do
          before(:each) do
            TestDocument.database.stub!(:get).and_return({
              'class' => 'WrongClass',
              '_id' => 'document-id',
              '_rev' => '1-12345'
            })
          end
          
          it_should_behave_like "document does not exist (for #load!)"
        end
      end
      
      context "multiple documents" do
        def do_load
          TestDocument.load!('document-1', 'document-2', 'document-3')
        end
        
        context "all documents exist" do
          it_should_behave_like "loading multiple documents successfully"
        end
        
        context "some documents do not exist or have incorrect class" do
          before(:each) do
            @result = {
              'total_rows' => 3,
              'offset' => 0,
              'rows' => [
                { 'id' => 'document-1', 'key' => 'document-1', 'doc' => { 'class' => 'TestDocument', '_id' => 'document-1', '_rev' => '1-12345', 'name' => 'First Document' } },
                { 'error' => 'not_found', 'key' => 'document-2' },
                { 'id' => 'document-3', 'key' => 'document-3', 'doc' => { 'class' => 'WrongClass', '_id' => 'document-3', '_rev' => '1-12345' } }
              ]
            }

            TestDocument.database.stub!(:post).and_return(@result)
          end
          
          it "should raise a Recliner::DocumentNotFound exception" do
            lambda { do_load }.should raise_error(Recliner::DocumentNotFound)
          end
        end
      end
    end
  end
end
