require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

module Recliner
  describe ViewGenerator do
    describe "#generate" do
      context "with :key option only" do
        subject { ViewGenerator.new(:key => :name) }
        
        it "should return a map function only" do
          result = subject.generate
          result[0].should be_an_instance_of(ViewFunction::Map)
          result[1].should be_nil
        end
        
        it "should create a map function that emits by the given key" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              emit(doc.name, doc);
            }")
        end
      end
      
      context "with Array :key option" do
        subject { ViewGenerator.new(:key => [:name, :age]) }
        
        it "should create a map function that emits by the given keys" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              emit([doc.name, doc.age], doc);
            }")
        end
      end
      
      context "with :order option only" do
        subject { ViewGenerator.new(:order => :age) }
        
        it "should create a map function that emits by the given order" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              emit(doc.age, doc);
            }")
        end
      end

      context "with String :conditions option" do
        subject { ViewGenerator.new(:conditions => 'doc.foo && doc.bar == "123"') }
        
        it "should create a map function that scopes to the given conditions" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              if ((doc.foo && doc.bar == \"123\")) {
                emit(doc._id, doc);
              }
            }")
        end
      end

      context "with Hash :conditions option" do
        subject { ViewGenerator.new(:conditions => { :baz => true, :foo => 'abc' }) }
        
        it "should create a map function that scopes to the given conditions" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              if (doc.baz && doc.foo === \"abc\") {
                emit(doc._id, doc);
              }
            }").or(
            "function(doc) {
              if (doc.foo === \"abc\" && doc.baz) {
                emit(doc._id, doc);
              }
            }")
        end
      end

      context "with :select option" do
        subject { ViewGenerator.new(:select => :name) }
        
        it "should create a map function that emits an object with the selected key" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              emit(doc._id, {\"name\": doc.name});
            }")
        end
      end
      
      context "with Array :select option" do
        subject { ViewGenerator.new(:select => [:_id, :name]) }
        
        it "should create a map function that emits an object with the selected key" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              emit(doc._id, {\"_id\": doc._id, \"name\": doc.name});
            }")
        end
      end

      context "all options" do
        subject {
          ViewGenerator.new(:order => :age, :conditions! => { :deleted => false }, :conditions => 'doc.age > 5', :select => [:_id, :name, :age])
        }
        
        it "should generate the correct map function" do
          subject.generate[0].should be_equivalent_to(
            "function(doc) {
              if (!doc.deleted && (doc.age > 5)) {
                emit(doc.age, {\"_id\": doc._id, \"name\": doc.name, \"age\": doc.age});
              }
            }"
          )
        end
      end
    end
  end
end
