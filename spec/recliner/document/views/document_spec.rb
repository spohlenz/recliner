require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe ViewDocument do
    it { should be_a_kind_of(Recliner::Document) }
    
    it "should have a language property = 'javascript'" do
      subject.language.should == 'javascript'
    end
    
    it "should have a views property" do
      subject.views.should be_a_kind_of(Recliner::Map)
      subject.views.should == {}
    end
    
    describe "#update_views" do
      def do_update
        subject.update_views({
          :view1 => View.new(:map => 'view 1'),
          :view2 => View.new(:map => 'view 2 (map)', :reduce => 'view 2 (reduce)')
        })
      end
      
      shared_examples_for "#update_views update required" do
        before(:each) do
          Recliner.stub!(:put)
        end
        
        it "should save the document" do
          subject.should_receive(:save!)
          do_update
        end
      end
      
      context "ViewDocument is unsaved" do
        it_should_behave_like "#update_views update required"
      end
      
      context "ViewDocument is saved and has changed views" do
        subject { ViewDocument.new(:id => '_design/Test') }
        
        before(:each) do
          subject.views[:view1] = View.new(:map => 'old view 1')
          save_with_stubbed_database!(subject)
        end
        
        it_should_behave_like "#update_views update required"
      end
      
      context "ViewDocument is saved but has no changed views" do
        before(:each) do
          subject.views[:view1] = View.new(:map => 'view 1')
          subject.views[:view2] = View.new(:map => 'view 2 (map)', :reduce => 'view 2 (reduce)')
          save_with_stubbed_database!(subject)
        end
        
        it "should not resave the document" do
          subject.should_not_receive(:save!)
          do_update
        end
      end
    end
    
    describe "#invoke" do
      before(:each) do
        @view1 = View.new(:map => 'view 1')
        @view2 = View.new(:map => 'view 2 (map)', :reduce => 'view 2 (reduce)')
        subject.views.replace(:view1 => @view1, :view2 => @view2)
        subject.id = '_design/TestDocument'
        save_with_stubbed_database!(subject)
        
        @database = mock('database')
        subject.stub!(:database).and_return(@database)
      end
      
      it "should invoke the correct view" do
        @view1.should_receive(:invoke).with(@database, "_design/TestDocument/_view/view1")
        subject.invoke('view1')
      end
      
      it "should pass the view arguments to the view" do
        @view2.should_receive(:invoke).with(@database, "_design/TestDocument/_view/view2", 1, 2, 3, :foo => 'bar')
        subject.invoke('view2', 1, 2, 3, :foo => 'bar')
      end
      
      it "should return the result of the view invocation" do
        @view1.stub!(:invoke).and_return('view result')
        subject.invoke('view1').should == 'view result'
      end
    end
  end
end
