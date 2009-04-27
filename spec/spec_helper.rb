require 'rubygems'
require 'spec'

# Require matchers and helpers

Dir[File.dirname(__FILE__) + '/matchers/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |f| require f }


require File.dirname(__FILE__) + '/../lib/recliner'

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
