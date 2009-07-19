require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

class ViewTestDocument < Recliner::Document
  property :name, String
end

describe "A Recliner::Document" do
  before(:each) {
    recreate_database!
    ViewTestDocument.instance_variable_set('@view_document', nil)
  }
  
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
    ViewTestDocument.views[:all].should == { :map => 'if (doc.class == "#{name}") emit(#{default_order}, doc);' }
  end
  
  it "should get the first/last items using the all view" do
    CouchDB.document_at('1', { :class => 'ViewTestDocument', :name => 'Aaron' })
    CouchDB.document_at('2', { :class => 'ViewTestDocument', :name => 'Ben' })
    CouchDB.document_at('3', { :class => 'ViewTestDocument', :name => 'Charlie' })
    
    ViewTestDocument.default_order :name
    ViewTestDocument.first.name.should == 'Aaron'
    ViewTestDocument.last.name.should == 'Charlie'
  end
  
  it "should have a getter/setter for default order" do
    ViewTestDocument.default_order :name
    ViewTestDocument.default_order.should == 'doc.name'
    
    ViewTestDocument.default_order :id
    ViewTestDocument.default_order.should == 'doc._id'
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
  
  describe "calling a view" do
    before(:each) do
      ViewTestDocument.view :by_name, :map => 'function(doc) { if (doc.class == \'ViewTestDocument\') emit(doc.name, doc); }'
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
end
