class Recliner::Document
  class_inheritable_accessor :database_uri
  
  def initialize(attributes={})
    self.attributes = self.class.default_attributes(self).merge(attributes)
    @new_record = true
  end
  
  autoload :Properties,    'recliner/properties'
  autoload :Views,         'recliner/views'
  autoload :PrettyInspect, 'recliner/pretty_inspect'
  
  include Properties, Views, PrettyInspect
  
  # Define core properties
  
  property :id,  String, :as => '_id', :default => lambda { generate_guid }
  property :rev, String, :as => '_rev'
  
  # Define default views
  
  # view :all, :map => "if (doc.class == '#{name}') emit(null, doc)"
  
  # Special case for id setter as old document needs to be deleted if the id is changed
  def id=(new_id)
    @old_id = id unless new_record?
    attributes['_id'] = new_id
  end
  
  # If the doc id has changed, we need to delete the old document when saving
  def id_changed?
    @old_id && @old_id != id
  end
  
  #
  #
  #
  def save
    save!
  rescue
    false
  end
  
  #
  #
  #
  def save!
    raise Recliner::DocumentNotSaved unless valid?
    
    result = self.class.database.put(id, attributes_with_class)
    self.class.database.delete("#{@old_id}?rev=#{rev}") if id_changed?
    
    self.id = result['id']
    self.rev = result['rev']
    
    @new_record = false
    
    true
  end
  
  #
  #
  #
  def new_record?
    @new_record
  end
  
  # Two documents are considered equal if they share the same document id and class
  def ==(other)
    other.class == self.class && other.id == self.id
  end
  
  # TODO: Extract out into Validation module
  def valid?
    true
  end
  
  class << self
    #
    #
    #
    def load(*ids)
      if ids.size == 1
        load_single(ids.first)
      else
        load_multiple(ids)
      end
    end
    
    #
    #
    #
    def use_database!(uri)
      @database = nil
      self.database_uri = uri
    end
    
    #
    #
    #
    def database
      @database ||= Recliner::Database.new(database_uri)
    end
  
  private
    def load_single(id)
      attrs = database.get(id)
      instantiate_from_database(attrs)
    end
    
    def load_multiple(ids)
      result = database.post('_all_docs?include_docs=true', { :keys => ids })
      result['rows'].map { |row|
        raise Recliner::DocumentNotFound unless row['doc']
        instantiate_from_database(row['doc'])
      }
    end
    
    def instantiate_from_database(attrs)
      raise Recliner::DocumentNotFound if name != 'Recliner::Document' && name != attrs['class']
      
      klass = attrs['class'].constantize
      
      returning(klass.new) do |record|
        properties.each do |name, property|
          record.attributes[property.as] = property.type.from_couch(attrs[property.as])
        end
        
        record.instance_variable_set("@new_record", false)
      end
    end
  end
end
