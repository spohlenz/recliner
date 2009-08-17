require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Recliner::Document, "change tracking" do
  subject { UniqueDocument.create!(:name => 'Original') }
  
  describe "An unchanged document" do
    it { should_not be_changed }
    
    it "should have an empty changed array" do
      subject.changed.should == []
    end
    
    it "should have an empty changes hash" do
      subject.changes.should == {}
    end
    
    it "should have old attributes equal to current attributes" do
      subject.old_attributes.should == subject.attributes
    end
  end
  
  describe "A changed document" do
    before(:each) do
      subject.name = 'Changed'
    end
    
    it { should be_changed }
    
    it "should have an array of changed attributes" do
      subject.changed.should == [ 'name' ]
    end
    
    it "should have a changes hash" do
      subject.changes.should == { 'name' => ['Original', 'Changed'] }
    end
    
    it "should reset changes/changed when saved" do
      subject.save!
      subject.changed.should == []
      subject.changes.should == {}
    end
    
    it "should have a hash of old attributes" do
      subject.old_attributes.should == {
        'name' => 'Original',
        '_id'  => subject.id,
        '_rev' => subject.rev,
        'country' => nil
      }
    end
  end
end
