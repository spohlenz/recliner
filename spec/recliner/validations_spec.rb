require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Recliner, "Validations" do
  before(:each) do
    @validation_repairs = ActiveModel::ValidationsRepairHelper::Toolbox.record_validations(ValidatedDocument)
  end
  
  after(:each) do
    ActiveModel::ValidationsRepairHelper::Toolbox.reset_validations(@validation_repairs)
  end
  
  describe "An invalid Recliner::Document" do
    before(:each) do
      ValidatedDocument.validates_presence_of :name
    end
    
    subject { ValidatedDocument.new }
  
    it "should not be valid (valid? returns false)" do
      subject.should_not be_valid
    end
  
    it "should be invalid (invalid? returns true)" do
      subject.should be_invalid
    end
  
    it "should have an errors object" do
      subject.errors.should be_instance_of(Recliner::Errors)
    end
  
    it "should not save" do
      subject.save.should be_false
    end
  
    it "should raise a DocumentInvalid exception on save!" do
      lambda {
        subject.save!
      }.should raise_error(Recliner::DocumentInvalid)
    end
  
    it "should save when it becomes valid" do
      subject.name = 'Valid'
      subject.save.should be_true
    end
  end
  
  describe "validation with :on => :create" do
    before(:each) do
      ValidatedDocument.validates_presence_of :name, :on => :create
    end
    
    subject { ValidatedDocument.new }
    
    describe "new document" do
      it "should not be valid" do
        subject.should_not be_valid
      end

      it "should not save" do
        subject.save.should be_false
      end
      
      it "should raise a DocumentInvalid exception on save!" do
        lambda {
          subject.save!
        }.should raise_error(Recliner::DocumentInvalid)
      end
    end

    describe "existing document" do
      before(:each) do
        subject.name = 'Valid'
        subject.save!
        subject.name = nil
      end
      
      it "should be valid" do
        subject.should be_valid
      end
    
      it "should save" do
        subject.save.should be_true
      end
      
      it "should not raise a DocumentInvalid exception on save!" do
        lambda {
          subject.save!
        }.should_not raise_error(Recliner::DocumentInvalid)
      end
    end
  end

  describe "validation with :on => :update" do
    before(:each) do
      ValidatedDocument.validates_presence_of :name, :on => :update
    end
    
    subject { ValidatedDocument.new }
    
    describe "new document" do
      it "should be valid" do
        subject.should be_valid
      end

      it "should save" do
        subject.save.should be_true
      end
      
      it "should not raise a DocumentInvalid exception on save!" do
        lambda {
          subject.save!
        }.should_not raise_error(Recliner::DocumentInvalid)
      end
    end

    describe "existing document" do
      before(:each) do
        subject.name = 'Valid'
        subject.save!
        subject.name = nil
      end
      
      it "should not be valid" do
        subject.should_not be_valid
      end
    
      it "should not save" do
        subject.save.should_not be_true
      end
      
      it "should raise a DocumentInvalid exception on save!" do
        lambda {
          subject.save!
        }.should raise_error(Recliner::DocumentInvalid)
      end
    end
  end
  
  ValidationMethods = [
    :validates_acceptance_of,
    :validates_confirmation_of,
    :validates_exclusion_of,
    :validates_format_of,
    :validates_inclusion_of,
    :validates_length_of,
    :validates_numericality_of,
    :validates_presence_of
  ]
  
  it "should include ActiveModel validations" do
    ValidationMethods.each do |validation_method|
      ValidatedDocument.should respond_to(validation_method)
    end
  end
end
