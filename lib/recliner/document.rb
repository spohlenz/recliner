require 'active_support'
require 'uuid'

class Recliner::Document
  class_inheritable_accessor :database_uri
  
  def initialize(attributes={})
    self.attributes = attributes
    self.id ||= generate_guid
    
    @new_record = true
  end
  
  # Define core properties
  
  autoload :Properties, 'recliner/properties'
  
  include Properties
  
  property :id,  String, :as => '_id'
  property :rev, String, :as => '_rev'
  
  def save
    result = self.class.database.put(id, attributes_with_class)
    
    self.id = result['id']
    self.rev = result['rev']
    
    @new_record = false
    
    true
  rescue
    false
  end
  
  def new_record?
    @new_record
  end
  
  class << self
    def load(id)
      attrs = database.get(id)
      raise Recliner::DocumentNotFound unless attrs['class'] == name
      
      attrs['id'] = attrs.delete('_id')
      attrs['rev'] = attrs.delete('_rev')
      
      returning new(attrs) do |record|
        record.instance_variable_set("@new_record", false)
      end
    end
    
    def use_database!(uri)
      @database = nil unless uri == database_uri
      self.database_uri = uri
    end
    
    def database
      @database ||= Recliner::Database.new(database_uri)
    end
  end

protected
  def generate_guid
    UUID.generate
  end
end
