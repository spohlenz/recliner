require File.dirname(__FILE__) + '/../spec_helper'

describe "Recliner::ViewDocument" do
  subject { Recliner::ViewDocument.new }
  
  it "should have a language property with default 'javascript'" do
    subject.language.should == 'javascript'
  end
  
  it "should have a views property with default {}" do
    subject.views.should == {}
  end
end
