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
  end
end
