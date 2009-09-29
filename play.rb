require 'recliner'
require 'faker'

class ZipCode
  def initialize(zip)
    @zip = zip.to_s
  end
  
  def inspect
    "#<ZipCode: #{@zip}>"
  end
end

Recliner::Conversions.register(ZipCode, :couch) { @zip }
Recliner::Conversions.register(:couch, ZipCode) { |str| ZipCode.new(str) }
Recliner::Conversions.register(Object, ZipCode) { |str| ZipCode.new(str) }

class User < Recliner::Document
  use_database! 'http://127.0.0.1:5984/recliner-play'
  
  property :name, String
  property :zip, ZipCode
  
  default_order :name
end

User.database.recreate!

20.times { User.new(:name => Faker::Name.name, :zip => 94941).save }
