require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    context "when invalid" do
      subject { TestDocument.new }
      
      before(:each) do
        subject.stub!(:valid?).and_return(false)
        subject.stub!(:database)
      end
      
      context "#save" do
        it "should return false" do
          subject.save.should be_false
        end
      end
      
      context "#save!" do
        before(:each) do
          subject.errors.stub!(:full_messages).and_return(["first error", "second error"])
        end
        
        it "should raise a Recliner::DocumentInvalid exception" do
          lambda { subject.save! }.should raise_error(Recliner::DocumentInvalid, "Validation failed: first error, second error")
        end
      end
    end
    
    describe "validation on create" do
      define_recliner_document :TestDocument do
        property :title, String
        validates_presence_of :title, :on => :create
      end
      
      subject { TestDocument.new }
      
      context "new document" do
        it { should_not be_valid }
      end
      
      context "existing document" do
        before(:each) do
          subject.title = 'A title'
          save_with_stubbed_database(subject)
          subject.title = nil
        end
        
        it { should be_valid }
      end
    end
    
    describe "validation on update" do
      define_recliner_document :TestDocument do
        property :title, String
        validates_presence_of :title, :on => :update
      end
      
      subject { TestDocument.new }
      
      context "new document" do
        it { should be_valid }
      end
      
      context "existing document" do
        before(:each) do
          subject.title = 'A title'
          save_with_stubbed_database(subject)
          subject.title = nil
        end
        
        it { should_not be_valid }
      end
    end
    
    describe "#errors" do
      subject { TestDocument.new.errors }
      
      it { should be_a_kind_of(ActiveModel::Errors) }
      it { should be_an_instance_of(Recliner::Errors) }
    end
    
    describe "skipping validation when saving" do
      before(:each) do
        subject.stub!(:save_without_validation).and_return(true)
      end
      
      subject { TestDocument.new }
      
      it "should not validate the document" do
        subject.should_not_receive(:valid?)
        subject.save(false)
      end
      
      it "should save the document" do
        subject.should_receive(:save_without_validation).and_return(true)
        subject.save(false)
      end
      
      it "should return true" do
        subject.save(false).should be_true
      end
    end
  end
end
