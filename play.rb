require 'lib/recliner'
require 'faker'

class User < Recliner::Document
  use_database! 'http://127.0.0.1:5984/recliner-play'
  
  property :name, String
  
  view :by_name, :map => "if (doc.class == 'User') emit(doc.title.en, doc)"
end

User.database.delete!
User.database.create!

20.times { User.new(:name => Faker::Name.name).save }
