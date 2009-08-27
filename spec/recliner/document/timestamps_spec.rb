require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    describe "#timestamps!" do
      define_recliner_document :TestDocument do
        timestamps!
      end
      
      it "should define a Time property updated_at" do
        TestDocument.properties.should include(:updated_at)
        TestDocument.properties[:updated_at].type.should == Time
      end
      
      it "should define a Time property created_at" do
        TestDocument.properties.should include(:created_at)
        TestDocument.properties[:created_at].type.should == Time
      end
    end
    
    context "with updated_at property" do
      define_recliner_document :TestDocument do
        property :updated_at, Time
      end
      
      subject { TestDocument.new }
      
      context "when saved" do
        before(:each) do
          save_with_stubbed_database(subject)
        end
        
        it "should set the updated_at property to the current time" do
          subject.updated_at.should be_close(Time.now, 1)
        end
      end
    end
    
    context "with updated_on property" do
      define_recliner_document :TestDocument do
        property :updated_on, Date
      end
      
      subject { TestDocument.new }
      
      context "when saved" do
        before(:each) do
          save_with_stubbed_database(subject)
        end
        
        it "should set the updated_on property to the current date" do
          subject.updated_on.should == Date.today
        end
      end
    end
    
    context "with created_at column" do
      define_recliner_document :TestDocument do
        property :created_at, Time
      end
      
      subject { TestDocument.new }
      
      context "when created" do
        it "should set the created_at property to the current time" do
          save_with_stubbed_database(subject)
          subject.created_at.should be_close(Time.now, 1)
        end
      end
      
      context "when updated" do
        before(:each) do
          save_with_stubbed_database(subject)
          @old_time = subject.created_at
        end
        
        it "should not change the created_at property" do
          save_with_stubbed_database(subject)
          subject.created_at.should == @old_time
        end
      end
    end
    
    context "with created_on property" do
      define_recliner_document :TestDocument do
        property :created_on, Date
      end
      
      subject { TestDocument.new }
      
      context "when created" do
        it "should set the created_on property to the current date" do
          save_with_stubbed_database(subject)
          subject.created_on.should == Date.today
        end
      end
      
      context "when updated" do
        before(:each) do
          save_with_stubbed_database(subject)
          
          @today = Date.today
          @tomorrow = 1.day.from_now
          
          Time.stub!(:now).and_return(@tomorrow)
        end
        
        it "should not change the created_on property" do
          save_with_stubbed_database(subject)
          subject.created_on.should == @today
        end
      end
    end
  end
end
