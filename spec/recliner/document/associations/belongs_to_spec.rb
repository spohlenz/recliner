require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe Document do
    describe "belongs_to association" do
      define_recliner_document :User
      define_recliner_document :Article do
        belongs_to :user
      end
      
      it "should add a reference property" do
        property = Article.properties[:user_id]
        
        property.should_not be_nil
        property.type.should == Recliner::Associations::Reference
      end
      
      context "with a null reference" do
        subject { Article.new }
        
        it "should be nil" do
          subject.user.should be_nil
        end
      end
      
      describe "assigning by id" do
        subject { Article.new }
        
        before(:each) do
          subject.user_id = '123'
        end
        
        it "should create a reference from the id" do
          subject.user_id.should be_an_instance_of(Recliner::Associations::Reference)
        end
      end
      
      it "should be assignable" do
        user = User.new
        article = Article.new
        
        article.user = user
        article.user.should == user
      end
    end
  end
end
