require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Recliner
  module RestfulHelpers
    def do_get(params=nil)
      if params
        Recliner.get('http://127.0.0.1:5984/recliner-spec/some-document', params)
      else
        Recliner.get('http://127.0.0.1:5984/recliner-spec/some-document')
      end
    end
  
    def do_put(payload={}, params=nil)
      if params
        Recliner.put('http://127.0.0.1:5984/recliner-spec/some-document', payload, params)
      else
        Recliner.put('http://127.0.0.1:5984/recliner-spec/some-document', payload)
      end
    end
  
    def do_post(payload={}, params=nil)
      if params
        Recliner.post('http://127.0.0.1:5984/recliner-spec/some-document', payload, params)
      else
        Recliner.post('http://127.0.0.1:5984/recliner-spec/some-document', payload)
      end
    end
  
    def do_delete(rev="12-12345")
      Recliner.delete("http://127.0.0.1:5984/recliner-spec/some-document?rev=#{rev}")
    end
    
    def do_request(options={})
      case request_type
      when :get
        send("do_get", options[:params])
      when :delete
        send("do_delete")
      else
        send("do_#{request_type}", options[:payload], options[:params])
      end
    end
  end
end

describe Recliner, ' configuration' do
  context "with String" do
    it "should directly set the Recliner::Document database" do
      Recliner::Document.should_receive(:use_database!).with('http://localhost:5984/database-from-string')
      Recliner.configuration = 'http://localhost:5984/database-from-string'
    end
  end
  
  context "with Hash" do
    it "should set the Recliner::Document database to a URI" do
      Recliner::Document.should_receive(:use_database!).with('http://localhost:5984/database-from-hash')
      Recliner.configuration = {
        'host'     => 'localhost',
        'port'     => 5984,
        'database' => 'database-from-hash'
      }
    end
  end
  
  context "with a non String/Hash" do
    it "should raise an ArgumentError" do
      lambda { Recliner.configuration = [1,2,3] }.should raise_error(ArgumentError, 'String or Hash expected')
    end
  end
end

describe Recliner, ' RESTful API' do
  include Recliner::RestfulHelpers
  
  shared_examples_for "all requests" do
    it "should convert the result to a hash" do
      do_request.should == { 'result' => 'ok' }
    end
    
    context "when CouchDB returns an error" do
      before(:each) do
        @response = mock('response', :code => '400', :body => '{"error":"query_parse_error","reason":"Bad URL query key:foo"}', :[] => 'application/json')
        @exception = RestClient::RequestFailed.new(@response)
        
        [ :get, :post, :put, :delete ].each do |http_method|
          RestClient.stub!(http_method).and_raise(@exception)
        end
      end
      
      it "should raise a CouchDB error" do
        lambda { do_request }.should raise_error(Recliner::CouchDBError, 'CouchDB error: query_parse_error (Bad URL query key:foo)')
      end
    end
  end
  
  shared_examples_for "all requests with parameters" do
    context "with parameters" do
      it "should quote string params" do
        RestClient.should_receive(request_type).with("http://127.0.0.1:5984/recliner-spec/some-document?key=%22abc-123%22").and_return('{}')
        do_request :params => { :key => 'abc-123' }
      end

      it "should not quote integer params" do
        RestClient.should_receive(request_type).with("http://127.0.0.1:5984/recliner-spec/some-document?limit=5").and_return('{}')
        do_request :params => { :limit => 5 }
      end
      
      it "should convert array params" do
        RestClient.should_receive(request_type).with("http://127.0.0.1:5984/recliner-spec/some-document?array=[123,%22hello%22]").and_return('{}')
        do_request :params => { :array => [123, "hello"] }
      end
      
      it "should convert hash params" do
        RestClient.should_receive(request_type).with("http://127.0.0.1:5984/recliner-spec/some-document?hash=%7B%22foo%22:%22bar%22%7D").and_return('{}')
        do_request :params => { :hash => { :foo => 'bar' } }
      end
    end
  end
  
  describe "GET an existing document" do
    it_should_behave_like "all requests"
    it_should_behave_like "all requests with parameters"
    
    def request_type; :get; end
    
    before(:each) do
      RestClient.stub!(:get).and_return('{"result":"ok"}')
    end
    
    it "should perform a GET request to the URI" do
      RestClient.should_receive(:get).with('http://127.0.0.1:5984/recliner-spec/some-document').and_return('{}')
      do_get
    end
  end
  
  describe "GET a missing document" do
    it "should raise a Recliner::DocumentNotFound exception" do
      RestClient.stub!(:get).and_raise(RestClient::ResourceNotFound)
      lambda { do_get }.should raise_error(Recliner::DocumentNotFound, "Could not find document at http://127.0.0.1:5984/recliner-spec/some-document")
    end
  end
  
  
  describe "PUT a document" do
    it_should_behave_like "all requests"
    it_should_behave_like "all requests with parameters"
    
    def request_type; :put; end
    
    before(:each) do
      RestClient.stub!(:put).and_return('{"result":"ok"}')
    end
    
    it "should perform a PUT request to the URI with the payload as JSON" do
      RestClient.should_receive(:put).with('http://127.0.0.1:5984/recliner-spec/some-document', '{"foo":"bar"}').and_return('{}')
      do_put({ :foo => 'bar' })
    end
    
    context "with an invalid revision" do
      before(:each) do
        response = mock('response', :code => '409')
        RestClient.stub!(:put).and_raise(RestClient::RequestFailed.new(response))
      end
      
      it "should raise a Recliner::StaleRevisionError" do
        lambda { do_put }.should raise_error(Recliner::StaleRevisionError)
      end
    end
  end
  
  
  describe "POST to a resource" do
    it_should_behave_like "all requests"
    it_should_behave_like "all requests with parameters"
    
    def request_type; :post; end
    
    before(:each) do
      RestClient.stub!(:post).and_return('{"result":"ok"}')
    end
    
    it "should perform a POST request to the URI with the payload as JSON" do
      RestClient.should_receive(:post).with('http://127.0.0.1:5984/recliner-spec/some-document', '{"foo":"bar"}').and_return('{}')
      do_post({ :foo => 'bar' })
    end
  end
  
  describe "POST to a missing resource" do
    it "should raise a Recliner::DocumentNotFound exception" do
      RestClient.stub!(:post).and_raise(RestClient::ResourceNotFound)
      lambda { do_post }.should raise_error(Recliner::DocumentNotFound, "Could not find document at http://127.0.0.1:5984/recliner-spec/some-document")
    end
  end
  
  
  describe "DELETE a document" do
    it_should_behave_like "all requests"
    
    def request_type; :delete; end
    
    before(:each) do
      RestClient.stub!(:delete).and_return('{"result":"ok"}')
    end
    
    it "should perform a DELETE request to the URI" do
      RestClient.should_receive(:delete).with('http://127.0.0.1:5984/recliner-spec/some-document?rev=12-12345').and_return('{}')
      do_delete
    end
    
    context "with an invalid revision" do
      before(:each) do
        response = mock('response', :code => '409')
        RestClient.stub!(:delete).and_raise(RestClient::RequestFailed.new(response))
      end
      
      it "should raise a Recliner::StaleRevisionError" do
        lambda { do_delete }.should raise_error(Recliner::StaleRevisionError)
      end
    end
  end
  
  describe "DELETE a missing document" do
    it "should raise a Recliner::DocumentNotFound exception" do
      RestClient.stub!(:delete).and_raise(RestClient::ResourceNotFound)
      lambda { do_delete }.should raise_error(Recliner::DocumentNotFound, "Could not find document at http://127.0.0.1:5984/recliner-spec/some-document?rev=12-12345")
    end
  end
end
