require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Recliner::Document, "validates_uniqueness_of" do
  before(:each) do
    @validation_repairs = ActiveModel::ValidationsRepairHelper::Toolbox.record_validations(UniqueDocument)
  end
  
  after(:each) do
    ActiveModel::ValidationsRepairHelper::Toolbox.reset_validations(@validation_repairs)
  end
  
  subject { UniqueDocument.new }
  
  describe "with no options" do
    before(:each) do
      UniqueDocument.validates_uniqueness_of :name
    end
    
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
  
  describe "with scope option" do
    before(:each) do
      UniqueDocument.validates_uniqueness_of :name, :scope => :country
    end
    
    subject { UniqueDocument.new(:country => 'USA') }
    
    describe "no other documents exist with the same name/country" do
      before(:each) do
        UniqueDocument.create!(:name => 'Test', :country => 'Australia')
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
    
    describe "another document with the same name and country exists" do
      before(:each) do
        UniqueDocument.create!(:name => 'Test', :country => 'USA')
      end
      
      it "should not be valid" do
        subject.name = 'Test'
        subject.should_not be_valid
      end
    end
  end
  
  describe "with custom view (single key)" do
    before(:each) do
      UniqueDocument.view :custom_view, :key => :name, :select => :_id, :conditions! => {}
      UniqueDocument.validates_uniqueness_of :name, :view => :custom_view
    end
    
    subject { UniqueDocument.new }
    
    describe "no other documents exist with the same name/country" do
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
    
    describe "another document with the same name and country exists" do
      before(:each) do
        ValidatedDocument.create!(:name => 'Test')
      end
      
      it "should not be valid" do
        subject.name = 'Test'
        subject.should_not be_valid
      end
    end
  end
  
  describe "with custom view (multiple keys)" do
    before(:each) do
      UniqueDocument.view :custom_view, :key => [:name, :country], :select => :_id, :conditions! => {}
      UniqueDocument.validates_uniqueness_of :name, :view => :custom_view
    end
    
    subject { UniqueDocument.new(:country => 'USA') }
    
    describe "no other documents exist with the same name/country" do
      before(:each) do
        UniqueDocument.create!(:name => 'Test', :country => 'Australia')
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
    
    describe "another document with the same name and country exists" do
      before(:each) do
        ValidatedDocument.create!(:name => 'Test', :country => 'USA')
      end
      
      it "should not be valid" do
        subject.name = 'Test'
        subject.should_not be_valid
      end
    end
  end
end