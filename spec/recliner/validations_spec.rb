require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'models/validated_document'

describe "An invalid Recliner::Document" do
  before(:each) do
    @doc = ValidatedDocument.new
    @doc.valid?
  end
  
  it "should not be valid (valid? returns false)" do
    @doc.should_not be_valid
  end
  
  it "should be invalid (invalid? returns true)" do
    @doc.should be_invalid
  end
  
  it "should have an errors object" do
    @doc.errors.should be_instance_of(ActiveModel::Errors)
  end
  
  it "should not save" do
    @doc.save.should be_false
  end
  
  it "should raise a DocumentInvalid exception on save!" do
    lambda {
      @doc.save!
    }.should raise_error(Recliner::DocumentInvalid)
  end
  
  it "should save when it becomes valid" do
    @doc.name = 'Valid'
    @doc.save.should be_true
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
