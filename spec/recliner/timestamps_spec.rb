require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "A time-stamped document" do
  subject { TimestampedDocument.new }
  
  it "should have a created_at property" do
    TimestampedDocument.properties[:created_at].type.should == Time
  end
  
  it "should have an updated_at property" do
    TimestampedDocument.properties[:updated_at].type.should == Time
  end
  
  it "should set the created_at time on creation" do
    Time.freeze do
      subject.save
      subject.created_at.should == Time.now
    end
  end
  
  it "should not set the created_at time on update" do
    subject.save
    
    Time.freeze do
      subject.save
      subject.created_at.should_not == Time.now
    end
  end
  
  it "should set the updated_at time on creation" do
    Time.freeze do
      subject.save
      subject.updated_at.should == Time.now
    end
  end
  
  it "should set the updated_at time on update" do
    subject.save
    
    Time.freeze do
      subject.save
      subject.updated_at.should == Time.now
    end
  end
end
