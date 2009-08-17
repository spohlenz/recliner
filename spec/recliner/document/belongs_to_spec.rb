require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "A Document which belongs to another" do
  before(:each) do
    @child = ChildDocument.new
    @parent = ParentDocument.new
  end
  
  it "should have a property for the parent id" do
    @child.properties.keys.should include(:parent_id)
  end
  
  it "should have a setter/getter for the parent" do
    @child.parent = @parent
    @child.parent.should == @parent
  end
  
  it "should set the parent id when assigning the parent" do
    @child.parent = @parent
    @child.parent_id.should == @parent.id
  end
  
  it "should load the parent if the id is set and parent is nil" do
    @parent.save
    
    @child.parent_id = @parent.id
    @child.parent.should == @parent
  end
end
