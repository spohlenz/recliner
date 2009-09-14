module Recliner
  class ViewDocument < Recliner::Document
    property :language, String, :default => 'javascript'
    property :views, Map(String => View)
    
    def update_views(new_views)
      self.views = views.dup.replace(new_views)
      save! if changed?
    end
    
    def invoke(view, *args)
      views[view].invoke(database, "#{id}/_view/#{view}", *args)
    end
  end
end
