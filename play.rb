require 'recliner'
require 'faker'

class User < Recliner::Document
  use_database! 'http://127.0.0.1:5984/recliner-play'
  
  property :name, String
  
  default_order :name
end

User.database.recreate!

20.times { User.new(:name => Faker::Name.name).save }
