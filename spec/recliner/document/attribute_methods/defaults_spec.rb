require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    context "with properties with default values" do
      define_recliner_document :TestDocument do
        property :name, String, :default => 'Hello'
        property :age, Integer, :default => 21
        property :no_default, String
      end

      subject { TestDocument.new }
      
      it "should initialize the attributes to their default values" do
        subject.name.should == 'Hello'
        subject.age.should == 21
      end
      
      it "should not initialize attributes without default values" do
        subject.no_default.should be_nil
      end
    end
  end
end
