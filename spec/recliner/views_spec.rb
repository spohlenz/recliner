require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'models/view_test'
require 'models/basic'

describe "Recliner::ViewDocument" do
  subject { Recliner::ViewDocument.new }
  
  it "should be a Recliner::Document" do
    subject.should be_a_kind_of(Recliner::Document)
  end
  
  it "should have a language property with default 'javascript'" do
    subject.language.should == 'javascript'
  end
  
  it "should have a views property with default {}" do
    subject.views.should == {}
  end
end

describe "A Recliner::Document" do
  before(:each) do
    recreate_database!
    
    ViewTestDocument.reset!
  end
  
  subject { ViewTestDocument }
  
  it "should have a view document id" do
    subject.view_document_id.should == '_design/ViewTestDocument'
  end
  
  it "should create a new view document with the id" do
    CouchDB.no_document_at('_design/ViewTestDocument')
    subject.view_document.should be_an_instance_of(Recliner::ViewDocument)
    subject.view_document.id.should == '_design/ViewTestDocument'
    subject.view_document.new_record?.should be_true
  end
  
  it "should use an existing view document if present" do
    CouchDB.document_at('_design/ViewTestDocument',
      { :class => 'Recliner::ViewDocument', :views => { :all => { :map => 'function(doc) { emit(null, doc); }' } } })
    subject.view_document.views.should == { 'all' => { 'map' => 'function(doc) { emit(null, doc); }' } }
    subject.view_document.new_record?.should be_false
  end
  
  it "should have a default all view" do
    CouchDB.document_at('1', { :class => 'ViewTestDocument' })
    CouchDB.document_at('2', { :class => 'ViewTestDocument' })
    CouchDB.document_at('3', { :class => 'ViewTestDocument' })
    
    ViewTestDocument.all.map(&:id).should == ['1', '2', '3']
  end
  
  it "should get the first/last items using the all view" do
    CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
    CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
    CouchDB.document_at('3', { :class => 'ViewTestDocument', :name => 'Charlie' })
    
    ViewTestDocument.default_order :name
    ViewTestDocument.first.name.should == 'Aaron'
    ViewTestDocument.last.name.should == 'Charlie'
  end
  
  it "should get the count of the model" do
    CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
    ViewTestDocument.count.should == 1
    CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
    ViewTestDocument.count.should == 2
  end
  
  it "should have a getter/setter for default order" do
    ViewTestDocument.default_order :name
    ViewTestDocument.default_order.should == 'name'
    
    ViewTestDocument.default_order :id
    ViewTestDocument.default_order.should == '_id'
  end
  
  it "should have a getter/setter for default conditions" do
    ViewTestDocument.default_conditions :foo => true
    ViewTestDocument.default_conditions.should == { :foo => true }
  end
  
  describe "initializing views" do
    before(:each) do
      ViewTestDocument.view :test_map, :map => 'function(doc) { emit(null, doc); }'
    end
    
    it "should create a view if it doesn't already exist" do
      CouchDB.no_document_at('_design/ViewTestDocument')
      
      ViewTestDocument.initialize_views!
      CouchDB.get('_design/ViewTestDocument')['views']['test_map'].should == { 'map' => 'function(doc) { emit(null, doc); }' }
    end
    
    it "should update an existing view if it already exists" do
      CouchDB.document_at('_design/ViewTestDocument',
        { :class => 'Recliner::ViewDocument', :views => { :existing => { :map => 'function(doc) { emit(null, doc); }' } } })
      
      ViewTestDocument.initialize_views!
      CouchDB.get('_design/ViewTestDocument')['views']['test_map'].should == { 'map' => 'function(doc) { emit(null, doc); }' }
      CouchDB.get('_design/ViewTestDocument')['views']['existing'].should == { 'map' => 'function(doc) { emit(null, doc); }' }
    end
    
    it "should interpolate option values" do
      ViewTestDocument.view :test_interpolate, :map => 'function(doc) { emit("#{name}", doc); }'
      ViewTestDocument.initialize_views!
      
      CouchDB.get('_design/ViewTestDocument')['views']['test_interpolate'].should == { 'map' => 'function(doc) { emit("ViewTestDocument", doc); }' }
    end
  end
  
  describe "defining a map view" do
    before(:all) do
      ViewTestDocument.view :test_map, :map => 'function(doc) { emit(null, doc); }'
    end
    
    it "should create a test_map method" do
      ViewTestDocument.should respond_to(:test_map)
    end
    
    it "should add the view to the views list" do
      ViewTestDocument.views[:test_map].should_not be_nil
    end
  end
  
  describe "calling a map view" do
    before(:each) do
      ViewTestDocument.view :by_name, :map => 'function(doc) { if (doc.class == "ViewTestDocument") emit(doc.name, doc); }'
    end
    
    it "should initialize views when called" do
      CouchDB.no_document_at('_design/ViewTestDocument')
      ViewTestDocument.by_name
      CouchDB.should have_document.at('_design/ViewTestDocument')
    end
    
    it "should return a result" do
      CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
      CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
      
      result = ViewTestDocument.by_name
      
      result.should have(2).items
      result[0].name.should == 'Aaron'
      result[1].name.should == 'Ben'
    end
    
    it "should be callable with a key" do
      CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
      CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
      
      result = ViewTestDocument.by_name('Ben')
      result.should have(1).item
      result[0].name.should == 'Ben'
    end
    
    it "should return an empty array if no results found" do
      result = ViewTestDocument.by_name('Not there')
      result.should == []
    end
    
    it "should be callable with multiple keys" do
      CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
      CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
      CouchDB.document_at('3', { :class => 'ViewTestDocument', :name => 'Charlie' })
      
      result = ViewTestDocument.by_name('Ben', 'Aaron')
      result[0].name.should == 'Ben'
      result[1].name.should == 'Aaron'
    end
    
    it "should be callable with a keys option" do
      CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
      CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
      CouchDB.document_at('3', { :class => 'ViewTestDocument', :name => 'Charlie' })
      
      result = ViewTestDocument.by_name(:keys => ['Ben', 'Aaron'])
      result[0].name.should == 'Ben'
      result[1].name.should == 'Aaron'
    end
    
    it "should be callable with options" do
      CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
      CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
      CouchDB.no_document_at('3')
      
      result = ViewTestDocument.by_name(:descending => true)
      result[0].name.should == 'Ben'
      result[1].name.should == 'Aaron'
    end
  end
  
  # describe "calling a map/reduce view" do
  #   before(:each) do
  #     ViewTestDocument.view :count_by_name, :map => 'if (doc.class == "ViewTestDocument") emit(doc.name, 1);',
  #                                           :reduce => 'return sum(values);'
  #                                           
  #     CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
  #     CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
  #     CouchDB.document_at('3', { :class => 'ViewTestDocument', :name => 'Ben' })
  #   end
  #   
  #   it "should be callable without grouping" do
  #     ViewTestDocument.count_by_name.should == 3
  #   end
  #   
  #   it "should be callable with grouping" do
  #     ViewTestDocument.count_by_name(:group => true).should == { 'Aaron' => 1, 'Ben' => 2 }
  #   end
  #   
  #   it "should be callable with a key" do
  #     ViewTestDocument.count_by_name('Aaron').should == 1
  #     ViewTestDocument.count_by_name('Ben').should == 2
  #   end
  # end
  
  describe "- defining views" do
    describe "with no options" do
      before(:each) do
        ViewTestDocument.create!(:id => '1', :name => 'Ben')
        ViewTestDocument.create!(:id => '2', :name => 'Charlie')
        BasicDocument.create!
        
        ViewTestDocument.view :no_option_view
      end
      
      it "should only return instances of ViewTestDocument" do
        ViewTestDocument.no_option_view.size.should == 2
        ViewTestDocument.no_option_view.all? { |doc| doc.should be_an_instance_of(ViewTestDocument) }
      end
      
      it "should order by default order (id)" do
        ViewTestDocument.no_option_view.map(&:id).should == ['1', '2']
      end
    end
    
    describe "with :order option" do
      before(:each) do
        @names = %w(Aaron Charlie Rudolph Ben)
        @names.each { |name| ViewTestDocument.create!(:name => name) }
        
        ViewTestDocument.view :order_view, :order => :name
      end
      
      it "should order results with no key" do
        ViewTestDocument.order_view.map(&:name).should == @names.sort
      end
      
      it "should order results descending" do
        ViewTestDocument.order_view(:descending => true).map(&:name).should == @names.sort.reverse
      end
      
      it "should give correct results with single key" do
        ViewTestDocument.order_view('Charlie').first.name.should == 'Charlie'
        ViewTestDocument.order_view('Ben').first.name.should == 'Ben'
      end
      
      it "should give correct results with multiple keys" do
        ViewTestDocument.order_view('Charlie', 'Ben').map(&:name).should == ['Charlie', 'Ben']
      end
    end
    
    describe "with array :key option" do
      before(:each) do
        ViewTestDocument.create!(:id => '1', :name => 'A')
        ViewTestDocument.create!(:id => '2', :name => 'A')
        ViewTestDocument.create!(:id => '3', :name => 'B')
        ViewTestDocument.create!(:id => '4', :name => 'A')
        
        ViewTestDocument.view :key_view, :key => [ :name, :_id ]
      end
      
      it "should order results with no key" do
        ViewTestDocument.key_view.map(&:id).should == [ '1', '2', '4', '3' ]
      end
      
      it "should give correct results with single key" do
        ViewTestDocument.key_view(['A', '1']).first.id.should == '1'
        ViewTestDocument.key_view(['A', '4']).first.id.should == '4'
      end
    end
    
    describe "with :conditions option" do
      before(:each) do
        ViewTestDocument.create!(:id => '1', :name => 'A')
        ViewTestDocument.create!(:id => '2', :name => 'A')
        ViewTestDocument.create!(:id => '3', :name => 'B')
        ViewTestDocument.create!(:id => '4', :name => 'A')
      end
      
      it "should only fetch documents matching conditions string" do
        ViewTestDocument.view :string_conditions_view, :conditions => 'doc.name == "A"'
        ViewTestDocument.string_conditions_view.map(&:id).should == [ '1', '2', '4' ]
      end
      
      it "should only fetch documents matching conditions hash" do
        ViewTestDocument.view :hash_conditions_view, :conditions => { :name => 'A' }
        ViewTestDocument.hash_conditions_view.map(&:id).should == [ '1', '2', '4' ]
      end
    end
    
    describe "with :select option" do
      before(:each) do
        ViewTestDocument.create!(:id => '1', :name => 'A')
        ViewTestDocument.view :select_single_view, :select => :class
        ViewTestDocument.view :select_array_view, :select => [ :_id, :class ]
      end
      
      it "should only select chosen fields" do
        result = ViewTestDocument.select_single_view.first
        result.id.should be_nil
        result.name.should be_nil
      end
    end
  end
end
