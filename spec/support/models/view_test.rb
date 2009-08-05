class ViewTestDocument < Recliner::Document
  property :name, String
  
  def self.reset!
    instance_variable_set('@view_document', nil)
    instance_variable_set('@views_initialized', nil)
    
    default_order :id
    default_conditions :class => '#{name}'
  end
end
