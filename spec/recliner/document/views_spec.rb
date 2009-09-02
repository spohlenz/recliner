require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Recliner
  describe Document do
    define_recliner_document :TestDocument
    
    describe "#views" do
      it "should be a hash" do
        TestDocument.views.should be_an_instance_of(Hash)
      end
      
      it "should be memoized" do
        TestDocument.views[:foo] = 'bar'
        TestDocument.views[:foo].should == 'bar'
      end
      
      it "should be inheritable" do
        TestDocument.views[:foo] = 'bar'
        Recliner::Document.views.should_not have_key(:foo)
        
        Recliner::Document.views[:baz] = '123'
        Class.new(Recliner::Document).views[:baz].should == '123'
      end
    end
    
    describe "defining a view" do
      def define_view
        TestDocument.view :foo, :map => 'my map function'
      end
      
      it "should add the view name and options to the views hash" do
        define_view
        TestDocument.views[:foo].should == { :map => 'my map function' }
      end
      
      it "should create a class method to invoke the view" do
        define_view
        TestDocument.should respond_to(:foo)
      end
      
      it "should reset views" do
        TestDocument.instance_variable_set("@_views_initialized", true)
        define_view
        TestDocument.views_initialized?.should be_false
      end
    end
    
    describe "#view_document" do
      context "view document does not yet exist" do
        before(:each) do
          Recliner.stub!(:get).and_raise(DocumentNotFound)
        end
        
        it "should create a new ViewDocument" do
          TestDocument.view_document.should be_an_instance_of(Recliner::ViewDocument)
        end
        
        it "should set the document id to the correct design document path" do
          TestDocument.view_document.id.should == '_design/TestDocument'
        end
        
        it "should not save the record" do
          TestDocument.view_document.should be_a_new_record
        end
      end
      
      context "view document exists" do
        before(:each) do
          @result = {
            '_id' => '_design/TestDocument',
            '_rev' => '1-12345',
            'class' => 'Recliner::ViewDocument',
            'language' => 'javascript',
            'views' => {}
          }
          
          Recliner.stub!(:get).and_return(@result)
        end
        
        it "should load the ViewDocument" do
          Recliner.should_receive(:get).and_return(@result)
          TestDocument.view_document
        end
      end
    end
    
    describe "#initialize_views!" do
      context "views already initialized" do
        before(:each) do
          TestDocument.instance_variable_set("@_views_initialized", true)
          @view_document = mock('view document')
          TestDocument.stub!(:view_document).and_return(@view_document)
        end
        
        it "should not update the view document" do
          @view_document.should_not_receive(:update_views)
          TestDocument.initialize_views!
        end
      end
      
      context "views not yet initialized" do
        before(:each) do
          TestDocument.instance_variable_set("@_views_initialized", false)
          @view_document = mock('view document')
          @view_document.stub!(:update_views).and_return(true)
          TestDocument.stub!(:view_document).and_return(@view_document)
          TestDocument.stub!(:views).and_return({})
        end
      
        it "should update the view document" do
          TestDocument.stub!(:views).and_return({
            :view1 => { :map => 'view 1 map' },
            :view2 => { :map => 'view 2 map', :reduce => 'view 2 reduce' }
          })
          
          @view_document.should_receive(:update_views).with({
            :view1 => View.new(:map => 'view 1 map'),
            :view2 => View.new(:map => 'view 2 map', :reduce => 'view 2 reduce')
          })
          
          TestDocument.initialize_views!
        end
        
        it "should interpolate view options" do
          TestDocument.stub!(:views).and_return({
            :view => { :map => '#{name}' }
          })
          
          @view_document.should_receive(:update_views).with({
            :view => View.new(:map => 'TestDocument')
          })
          
          TestDocument.initialize_views!
        end
      
        it "should mark views as initialized" do
          TestDocument.initialize_views!
          TestDocument.views_initialized?.should be_true
        end
      end
    end
    
    describe "invoking a view" do
      before(:each) do
        TestDocument.view :foo, :map => 'my map function'
        TestDocument.stub!(:initialize_views!)
        @view_document = mock('view document')
        @view_document.stub!(:invoke).and_return('view result')
        TestDocument.stub!(:view_document).and_return(@view_document)
      end
      
      it "should initialize views" do
        TestDocument.should_receive(:initialize_views!)
        TestDocument.foo
      end
      
      it "should invoke the view on the view document" do
        @view_document.should_receive(:invoke).with('foo')
        TestDocument.foo
      end
      
      it "should pass the view arguements onto the view document invocation" do
        @view_document.should_receive(:invoke).with('foo', 1, 2, 3, :foo => 'bar')
        TestDocument.foo(1, 2, 3, :foo => 'bar')
      end
      
      it "should return the result of the view invocation" do
        TestDocument.foo.should == 'view result'
      end
    end
  end
end
