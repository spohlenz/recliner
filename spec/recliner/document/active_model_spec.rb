require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    subject { TestDocument.new }
    
    it "should behave like an ActiveModel object" do
      subject.to_model.should == subject
    end
    
    it "should have a model name" do
      name = TestDocument.model_name
      
      name.should == 'TestDocument'
      name.singular.should == 'test_document'
      name.plural.should == 'test_documents'
      name.element.should == 'test_document'
      name.collection.should == 'test_documents'
      name.partial_path.should == 'test_documents/test_document'
      name.human.should == 'test document'
    end
  end
end
