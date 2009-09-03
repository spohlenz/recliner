require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe View do
    context "with map option" do
      subject { View.new(:map => 'my map function') }
      
      it "should wrap map function in a ViewFunction::Map" do
        subject.map.should be_an_instance_of(ViewFunction::Map)
      end
      
      it "should serialize to couch" do
        subject.to_couch.should == {
          'map' => 'function(doc) { my map function }'
        }
      end
      
      it "should load from couch" do
        view = View.from_couch({
          'map' => 'function(doc) { my map function }'
        })
        
        view.map.to_s.should == 'function(doc) { my map function }'
        view.reduce.should be_nil
      end
      
      it "should be equal to another view with the same map function and no view" do
        subject.should == View.new(:map => 'my map function')
      end
      
      it "should not be equal to another view with the same map function but with a view" do
        subject.should_not == View.new(:map => 'my map function', :reduce => 'some reduce function')
      end
      
      it "should not be equal to another view with a different map function" do
        subject.should_not == View.new(:map => 'some other map function')
      end
    end
    
    context "with map and reduce options" do
      subject { View.new(:map => 'my map function', :reduce => 'my reduce function') }
      
      it "should wrap reduce function in a ViewFunction::Reduce" do
        subject.reduce.should be_an_instance_of(ViewFunction::Reduce)
      end
      
      it "should serialize to couch" do
        subject.to_couch.should == {
          'map' => 'function(doc) { my map function }',
          'reduce' => 'function(keys, values, rereduce) { my reduce function }'
        }
      end
      
      it "should load from couch" do
        view = View.from_couch({
          'map' => 'function(doc) { my map function }',
          'reduce' => 'function(keys, values, rereduce) { my reduce function }'
        })
        
        view.map.to_s.should == 'function(doc) { my map function }'
        view.reduce.to_s.should == 'function(keys, values, rereduce) { my reduce function }'
      end
      
      it "should be equal to another view with the same map and reduce functions" do
        subject.should == View.new(:map => 'my map function', :reduce => 'my reduce function')
      end
      
      it "should not be equal to another view with a different map function" do
        subject.should_not == View.new(:map => 'some other map function', :reduce => 'my reduce function')
      end
      
      it "should not be equal to another view with a different reduce function" do
        subject.should_not == View.new(:map => 'my map function', :reduce => 'some other reduce function')
      end
    end
    
    context "without map option" do
      before(:each) do
        @generator = mock('ViewGenerator instance')
        @generator.stub(:generate).and_return([ 'map function', 'reduce function' ])
        ViewGenerator.stub!(:new).and_return(@generator)
      end
      
      def create_view
        View.new(:order => 'name', :conditions => { :class => 'TestDocument' })
      end
      
      it "should generate a view function" do
        ViewGenerator.should_receive(:new).with(:order => 'name', :conditions => { :class => 'TestDocument' }).and_return(@generator)
        create_view
      end
      
      it "should assign map and reduce functions from the generator" do
        view = create_view
        
        view.map.should == 'map function'
        view.reduce.should == 'reduce function'
      end
    end
    
    describe "#invoke" do
      define_recliner_document :TestDocument
      
      subject { View.new(:map => 'map function') }
      
      before(:each) do
        @database = mock('database')
        @path = "_design/TestDocument/_view/test"
      end
      
      describe "options and keys" do
        context "with no keys" do
          before(:each) do
            @database.stub!(:get).and_return({ 'rows' => [] })
          end
        
          context "without options" do
            def invoke
              subject.invoke(@database, @path)
            end
          
            it "should GET the view with empty options" do
              @database.should_receive(:get).with(@path, {}).and_return({ 'rows' => [] })
              invoke
            end
          end
        
          context "with options" do
            def invoke
              subject.invoke(@database, @path, :limit => 1, :raw => true)
            end
            
            it "should GET the view with the given options (and without meta options)" do
              @database.should_receive(:get).with(@path, { :limit => 1 }).and_return({ 'rows' => [] })
              invoke
            end
          end
        end
      
        context "with a single key" do
          before(:each) do
            @database.stub!(:get).and_return({ 'rows' => [] })
          end
        
          context "without options" do
            def invoke
              subject.invoke(@database, @path, 'key')
            end
          
            it "should GET the view with the given key" do
              @database.should_receive(:get).with(@path, { :key => 'key' }).and_return({ 'rows' => [] })
              invoke
            end
          end
        
          context "with options" do
            def invoke
              subject.invoke(@database, @path, 'key', :limit => 1, :raw => true)
            end
          
            it "should GET the view with the given key and options (and without meta options)" do
              @database.should_receive(:get).with(@path, { :key => 'key', :limit => 1 }).and_return({ 'rows' => [] })
              invoke
            end
          end
        end
      
        context "with multiple keys" do
          before(:each) do
            @database.stub!(:post).and_return({ 'rows' => [] })
          end
        
          context "without options" do
            def invoke
              subject.invoke(@database, @path, 'key1', 'key2')
            end
          
            it "should POST to the view with the given keys and empty params" do
              @database.should_receive(:post).with(@path, { :keys => [ 'key1', 'key2' ] }, {}).and_return({ 'rows' => [] })
              invoke
            end
          end
        
          context "with options" do
            def invoke
              subject.invoke(@database, @path, 'key1', 'key2', :descending => true, :raw => true)
            end
          
            it "should POST to the view with the given keys and options (and without meta options)" do
              @database.should_receive(:post).with(@path, { :keys => [ 'key1', 'key2' ] },  { :descending => true }).and_return({ 'rows' => [] })
              invoke
            end
          end
        
          context "with keys option" do
            def invoke
              subject.invoke(@database, @path, :keys => [ 'key1', 'key2' ], :descending => true, :raw => true)
            end
          
            it "should POST to the view with the given keys and options (and without meta options)" do
              @database.should_receive(:post).with(@path, { :keys => [ 'key1', 'key2' ] },  { :descending => true }).and_return({ 'rows' => [] })
              invoke
            end
          end
        end
      end
      
      describe "results" do
        context "all results are instantiable" do
          before(:each) do
            @raw = {
              'rows' => [
                { 'id' => '123', 'value' => { 'class' => 'TestDocument', '_id' => '123', '_rev' => '1-12345' }, 'key' => 'TestDocument' },
                { 'id' => 'abc', 'value' => { 'class' => 'TestDocument', '_id' => 'abc', '_rev' => '1-12345' }, 'key' => 'TestDocument' },
              ]
            }
            @database.stub!(:get).and_return(@raw)
          end
          
          context "raw option not provided" do
            it "should instantiate results" do
              result = subject.invoke(@database, @path)
              
              result.all? { |i| i.should be_an_instance_of(TestDocument) }
              result[0].id.should == '123'
              result[1].id.should == 'abc'
            end
          end
          
          context "raw option provided" do
            it "should not instantiate results" do
              subject.invoke(@database, @path, :raw => true).should == @raw
            end
          end
        end
        
        context "results are not instantiable" do
          before(:each) do
            @raw = {
              'rows' => [
                { 'id' => '123', 'value' => 1, 'key' => 'TestDocument' },
                { 'id' => 'abc', 'value' => 2, 'key' => 'TestDocument' },
              ]
            }
            @database.stub!(:get).and_return(@raw)
          end
          
          it "should return raw values" do
            subject.invoke(@database, @path).should == [ 1, 2 ]
          end
        end
      end
    end
  end
end
