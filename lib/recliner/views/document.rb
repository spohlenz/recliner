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
    rescue DocumentNotFound
      # The view disappeared from the database while we were working with the view document.
      # Reset the revision, save the view document, and try to invoke the view again.
      self.rev = nil
      save! and retry
    end
  end
end
