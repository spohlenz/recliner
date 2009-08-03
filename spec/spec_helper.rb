require 'rubygems'
require 'spec'

# Require matchers and helpers

Dir[File.dirname(__FILE__) + '/matchers/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |f| require f }

require File.dirname(__FILE__) + '/../lib/recliner'

$LOAD_PATH.unshift(File.dirname(__FILE__))

DEFAULT_DATABASE = 'http://localhost:5984/recliner-test'

def recreate_database!
  RestClient.delete DEFAULT_DATABASE rescue nil
  RestClient.put DEFAULT_DATABASE, nil
end

def set_database!
  Recliner::Document.database_uri = DEFAULT_DATABASE
end

set_database!

Spec::Runner.configure do |config|
  config.before(:all) do
    set_database!
    recreate_database!
  end
end

class MyCustomClass
  attr_accessor :a, :b
  
  def initialize(a, b)
    @a = a; @b = b
  end
  
  def self.from_couch(h)
    new(h['a'], h['b']) if h
  end
  
  def to_couch
    { :a => a, :b => b }
  end
  
  def ==(other)
    other.is_a?(MyCustomClass) &&
      a == other.a && b == other.b
  end
end
