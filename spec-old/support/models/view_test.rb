class ViewTestDocument < Recliner::Document
  property :name, String
  
  def self.reset!
    reset_views!
    
    default_order :id
    default_conditions :class => '#{name}'
  end
end
