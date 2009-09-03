require 'spec'

# Require Recliner library
require File.dirname(__FILE__) + '/../lib/recliner'

# Require spec helpers
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

Spec::Runner.configure do |config|
  config.include ReclinerHelpers
  config.extend ReclinerMacros
end
