require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    describe "#validates_uniqueness_of" do
      define_recliner_document :TestDocument do
        property :name, String
        property :country, String
      end
      
      context "without scope" do
        before(:each) do
          TestDocument.validates_uniqueness_of :name
        end
        
        it "should create a view" do
          TestDocument.views[:_by_name_for_uniqueness].should == { :key => [ :name ], :select => :_id }
        end
        
        context "when validating" do
          subject { TestDocument.new(:id => 'abc', :name => 'Test') }
          
          it "should invoke the view with the document name" do
            TestDocument.should_receive(:_by_name_for_uniqueness).with(['Test']).and_return([])
            subject.valid?
          end
          
          context "view result is empty" do
            before(:each) { TestDocument.stub!(:_by_name_for_uniqueness).and_return([]) }
            it { should be_valid }
          end
          
          context "view result contains the current document id" do
            before(:each) { TestDocument.stub!(:_by_name_for_uniqueness).and_return([{ '_id' => 'abc' }]) }
            it { should be_valid }
          end
          
          context "view result contains another document id" do
            before(:each) { TestDocument.stub!(:_by_name_for_uniqueness).and_return([{ '_id' => '123' }]) }
            it { should_not be_valid }
          end
        end
      end
      
      context "with scope" do
        before(:each) do
          TestDocument.validates_uniqueness_of :name, :scope => :country
        end
        
        it "should create a view" do
          TestDocument.views[:_by_name_and_country_for_uniqueness].should == { :key => [ :name, :country ], :select => :_id }
        end
        
        context "when validating" do
          subject { TestDocument.new(:id => 'abc', :name => 'Test', :country => 'USA') }
          
          it "should invoke the view with the document name and country" do
            TestDocument.should_receive(:_by_name_and_country_for_uniqueness).with(['Test', 'USA']).and_return([])
            subject.valid?
          end
        end
      end
      
      context "with custom view" do
        before(:each) do
          TestDocument.view :my_custom_view, :key => :country
          @original_views = TestDocument.views
          
          TestDocument.validates_uniqueness_of :name, :view => :my_custom_view
        end
        
        it "should not create a view" do
          TestDocument.views.should == @original_views
        end
        
        context "when validating" do
          subject { TestDocument.new(:id => 'abc', :name => 'Test', :country => 'USA') }
          
          it "should invoke the view with the view key" do
            TestDocument.should_receive(:my_custom_view).with('USA').and_return([])
            subject.valid?
          end
        end
      end
    end
  end
end
