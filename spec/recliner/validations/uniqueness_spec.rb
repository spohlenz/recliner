require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Recliner::Document, "validates_uniqueness_of" do
  before(:each) do
    @validation_repairs = ActiveModel::ValidationsRepairHelper::Toolbox.record_validations(UniqueDocument)
  end
  
  after(:each) do
    ActiveModel::ValidationsRepairHelper::Toolbox.reset_validations(@validation_repairs)
  end
  
  describe "with no options" do
    before(:each) do
      UniqueDocument.validates_uniqueness_of :name
      UniqueDocument.all.map { |d| d.destroy }
    end
    
    subject { UniqueDocument.new }
    
    describe "no other documents exist with the same name" do
      before(:each) do
        UniqueDocument.create!(:name => 'Different')
      end
      
      it "should be valid when creating" do
        subject.name = 'Test'
        subject.should be_valid
      end
      
      it "should be valid when updating" do
        subject.name = 'Test'
        subject.save!

        subject.should be_valid
      end
    end
    
    describe "another document with the same name exists" do
      before(:each) do
        UniqueDocument.create!(:name => 'Test')
      end
      
      it "should not be valid" do
        subject.name = 'Test'
        subject.should_not be_valid
      end
    end
  end
end
