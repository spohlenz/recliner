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
      it { should_not be_read_only }
      
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
    
    describe "#read_only!" do
      subject { TestDocument.new }
      
      before(:each) do
        subject.read_only!
      end
      
      it "should mark the document as read only" do
        subject.should be_read_only
      end
      
      it "should freeze the attributes hash" do
        subject.attributes.should be_frozen
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
          
          it "should raise a StaleRevisionError exception" do
            lambda { do_save }.should raise_error(Recliner::StaleRevisionError)
          end
        end
      end
    end
    
    describe "#create" do
      shared_examples_for "creating a document with create" do
        it "should save the instance" do
          @instance.should_receive(:save)
          TestDocument.create
        end
        
        it "should return the instance" do
          TestDocument.create.should == @instance
        end
      end
      
      context "with no attributes" do
        before(:each) do
          @instance = TestDocument.new
          @instance.stub!(:save)
          TestDocument.stub!(:new).and_return(@instance)
        end
        
        it_should_behave_like "creating a document with create"
        
        it "should create an instance with no attributes" do
          TestDocument.should_receive(:new)
          TestDocument.create
        end
      end
      
      context "with attributes" do
        before(:each) do
          @instance = TestDocument.new
          @instance.stub!(:save)
          TestDocument.stub!(:new).and_return(@instance)
        end
        
        it_should_behave_like "creating a document with create"
        
        it "should create an instance with the given attributes" do
          TestDocument.should_receive(:new).with({ :id => 'abc-123' })
          TestDocument.create({ :id => 'abc-123' })
        end
      end
      
      context "with a block" do
        before(:each) do
          @instance = TestDocument.new
          @instance.stub!(:save)
          TestDocument.stub!(:new).and_return(@instance)
        end
        
        it_should_behave_like "creating a document with create"
        
        it "should yield the instance to the block before saving" do
          block_called = false
          TestDocument.create do |doc|
            block_called = true
            doc.should == @instance
            doc.should be_a_new_record
          end
          block_called.should be_true
        end
      end
    end
    
    describe "#create!" do
      shared_examples_for "creating a document with create!" do
        it "should save the instance" do
          @instance.should_receive(:save!)
          TestDocument.create!
        end
        
        it "should return the instance" do
          TestDocument.create!.should == @instance
        end
        
        it "should not catch exceptions" do
          @instance.stub!(:save!).and_raise(StaleRevisionError)
          lambda { TestDocument.create! }.should raise_error(StaleRevisionError)
        end
      end
      
      context "with no attributes" do
        before(:each) do
          @instance = TestDocument.new
          @instance.stub!(:save!)
          TestDocument.stub!(:new).and_return(@instance)
        end
        
        it_should_behave_like "creating a document with create!"
        
        it "should create an instance with no attributes" do
          TestDocument.should_receive(:new)
          TestDocument.create!
        end
      end
      
      context "with attributes" do
        before(:each) do
          @instance = TestDocument.new
          @instance.stub!(:save!)
          TestDocument.stub!(:new).and_return(@instance)
        end
        
        it_should_behave_like "creating a document with create!"
        
        it "should create an instance with the given attributes" do
          TestDocument.should_receive(:new).with({ :id => 'abc-123' })
          TestDocument.create!({ :id => 'abc-123' })
        end
      end
      
      context "with a block" do
        before(:each) do
          @instance = TestDocument.new
          @instance.stub!(:save!)
          TestDocument.stub!(:new).and_return(@instance)
        end
        
        it_should_behave_like "creating a document with create!"
        
        it "should yield the instance to the block before saving" do
          block_called = false
          TestDocument.create! do |doc|
            block_called = true
            doc.should == @instance
            doc.should be_a_new_record
          end
          block_called.should be_true
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
    
    describe "#delete" do
      subject { TestDocument.new(:id => 'document-id') }
      
      shared_examples_for "deleting successfully" do
        it "should mark the document as read only" do
          subject.delete
          subject.should be_read_only
        end
        
        it "should return itself" do
          subject.delete.should == subject
        end
      end
      
      context "on a new document" do
        it_should_behave_like "deleting successfully"
        
        it "should not perform a DELETE on the database" do
          subject.database.should_not_receive(:delete)
          subject.delete
        end
      end
      
      context "on an existing document" do
        before(:each) do
          save_with_stubbed_database(subject)
          
          @result = { 'ok' => true, 'id' => 'document-id', 'rev' => '1-12345' }
          subject.database.stub!(:delete).and_return(@result)
        end
        
        it "should perform a DELETE on the database" do
          subject.database.should_receive(:delete).with('document-id?rev=1-12345').and_return(@result)
          subject.delete
        end
        
        it_should_behave_like "deleting successfully"
      end
      
      context "on an already deleted document" do
        before(:each) do
          save_with_stubbed_database(subject)
          subject.database.stub!(:delete).and_raise(Recliner::DocumentNotFound)
        end
        
        it "should perform a DELETE on the database" do
          subject.database.should_receive(:delete).with('document-id?rev=1-12345').and_raise(Recliner::DocumentNotFound)
          subject.delete
        end
        
        it_should_behave_like "deleting successfully"
      end
      
      context "on a document with an invalid revision" do
        before(:each) do
          save_with_stubbed_database(subject)
          subject.database.stub!(:delete).and_raise(Recliner::StaleRevisionError)
        end
        
        it "should perform a DELETE on the database" do
          subject.database.should_receive(:delete).with('document-id?rev=1-12345').and_raise(Recliner::StaleRevisionError)
          subject.delete rescue nil
        end
        
        it "should raise a Recliner::StaleRevisionError exception" do
          lambda { subject.delete }.should raise_error(Recliner::StaleRevisionError)
        end
        
        it "should not mark the document as read only" do
          subject.delete rescue nil
          subject.should_not be_read_only
        end
      end
    end
    
    describe "#destroy" do
      subject { TestDocument.new(:id => 'document-id') }
      
      shared_examples_for "destroying successfully" do
        it "should mark the document as read only" do
          subject.destroy
          subject.should be_read_only
        end
        
        it "should return itself" do
          subject.destroy.should == subject
        end
      end
      
      context "on a new document" do
        it_should_behave_like "deleting successfully"
        
        it "should not perform a DELETE on the database" do
          subject.database.should_not_receive(:delete)
          subject.destroy
        end
      end
      
      context "on an existing document" do
        before(:each) do
          save_with_stubbed_database(subject)
          
          @result = { 'ok' => true, 'id' => 'document-id', 'rev' => '1-12345' }
          subject.database.stub!(:delete).and_return(@result)
        end
        
        it "should perform a DELETE on the database" do
          subject.database.should_receive(:delete).with('document-id?rev=1-12345').and_return(@result)
          subject.destroy
        end
        
        it_should_behave_like "destroying successfully"
      end
      
      context "on an already deleted document" do
        before(:each) do
          save_with_stubbed_database(subject)
          subject.database.stub!(:delete).and_raise(Recliner::DocumentNotFound)
        end
        
        it "should perform a DELETE on the database" do
          subject.database.should_receive(:delete).with('document-id?rev=1-12345').and_raise(Recliner::DocumentNotFound)
          subject.destroy
        end
        
        it_should_behave_like "destroying successfully"
      end
      
      context "on a document with an invalid revision" do
        before(:each) do
          save_with_stubbed_database(subject)
          subject.database.stub!(:delete).and_raise(Recliner::StaleRevisionError)
        end
        
        it "should perform a DELETE on the database" do
          subject.database.should_receive(:delete).with('document-id?rev=1-12345').and_raise(Recliner::StaleRevisionError)
          subject.destroy rescue nil
        end
        
        it "should raise a Recliner::StaleRevisionError exception" do
          lambda { subject.destroy }.should raise_error(Recliner::StaleRevisionError)
        end
        
        it "should not mark the document as read only" do
          subject.destroy rescue nil
          subject.should_not be_read_only
        end
      end
    end
    
    describe "#instantiate_from_database" do
      context "on Recliner::Document base class" do
        context "document can be instantiated" do
          def instantiate
            Recliner::Document.instantiate_from_database({
              'class' => 'TestDocument',
              '_id' => 'abc-123',
              '_rev' => '1-1234'
            })
          end
          
          it "should return an instance of the correct type" do
            instantiate.should be_an_instance_of(TestDocument)
          end
          
          it "should set the class's attributes" do
            instance = instantiate
            instance.id.should == 'abc-123'
            instance.rev.should == '1-1234'
          end
        end
        
        context "document class is not defined" do
          def instantiate
            Recliner::Document.instantiate_from_database({
              '_id' => 'abc-123',
              '_rev' => '1-1234'
            })
          end
          
          it "should raise a DocumentNotFound error" do
            lambda { instantiate }.should raise_error(DocumentNotFound)
          end
        end
      end
      
      context "on a subclass of Recliner::Document" do
        context "document can be instantiated" do
          def instantiate
            TestDocument.instantiate_from_database({
              'class' => 'TestDocument',
              '_id' => 'abc-123',
              '_rev' => '1-1234'
            })
          end
          
          it "should return an instance of the correct type" do
            instantiate.should be_an_instance_of(TestDocument)
          end
          
          it "should set the class's attributes" do
            instance = instantiate
            instance.id.should == 'abc-123'
            instance.rev.should == '1-1234'
          end
        end
        
        context "document class is not defined" do
          def instantiate
            TestDocument.instantiate_from_database({
              '_id' => 'abc-123',
              '_rev' => '1-1234'
            })
          end
          
          it "should raise a DocumentNotFound error" do
            lambda { instantiate }.should raise_error(DocumentNotFound)
          end
        end
        
        context "document class is different from subclass name" do
          def instantiate
            TestDocument.instantiate_from_database({
              'class' => 'NotATestDocument',
              '_id' => 'abc-123',
              '_rev' => '1-1234'
            })
          end
          
          it "should raise a DocumentNotFound error" do
            lambda { instantiate }.should raise_error(DocumentNotFound)
          end
        end
      end
    end
    
    describe "#with_database" do
      define_recliner_document :TestDocument1
      define_recliner_document :TestDocument2
      
      before(:each) do
        @database = mock('database')
      end
      
      it "should use the given database for all new documents within the block with the same class" do
        TestDocument1.with_database(@database) do
          TestDocument1.new.database.should == @database
          TestDocument2.new.database.should_not == @database
        end
      end
      
      specify "instances created within the block should continue to use the database" do
        instance = nil
        TestDocument1.with_database(@database) do
          instance = TestDocument1.new
        end
        instance.database.should == @database
      end
      
      specify "instances loaded within the block should continue to use the database" do
        @database.stub!(:get).and_return({ 'class' => 'TestDocument1', '_id' => '123', '_rev' => '1-12345' })
        
        instance = nil
        TestDocument1.with_database(@database) do
          instance = TestDocument1.load('123')
        end
        instance.database.should == @database
      end
      
      it "should not use the given database for documents created after the block" do
        TestDocument1.with_database(@database) {}
        TestDocument1.new.database.should_not == @database
      end
    end
  end
end
