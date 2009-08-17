require 'rubygems'
require 'spec'

# Require Recliner library
require File.dirname(__FILE__) + '/../lib/recliner'

DEFAULT_DATABASE = 'http://localhost:5984/recliner-test'

def recreate_database!
  RestClient.delete DEFAULT_DATABASE rescue nil
  RestClient.put DEFAULT_DATABASE, nil
end

def set_database!
  Recliner::Document.database_uri = DEFAULT_DATABASE
end

Spec::Runner.configure do |config|
  config.before(:each) do
    set_database!
    recreate_database!
  end
end

set_database!

# Require support files
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }
