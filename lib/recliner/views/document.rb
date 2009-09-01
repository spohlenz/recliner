module Recliner
  class ViewDocument < Recliner::Document
    property :language, String, :default => 'javascript'
    property :views, Map(String => View)
    
    def update_views(new_views)
      self.views = views.dup.replace(new_views)
      save! if changed?
    end
    
  #   def invoke(view, *keys)
  #     options = keys.extract_options!
  #     fetch(view, keys, options)
  #   end

  # private
  #   def fetch(view, keys, options)
  #     result = fetch_result(view, keys, options)
  #     result['rows'].map { |row|
  #       if row['value'].is_a?(Hash) && row['value']['class']
  #         self.class.instantiate_from_database(row['value'])
  #       else
  #         row['value']
  #       end
  #     }
  #   end
  #
  #   def fetch_result(view, keys, options)
  #     keys = options.delete(:keys) if options[:keys]
  #     
  #     case keys.size
  #     when 0
  #       database.get("#{id}/_view/#{view}", options)
  #     when 1
  #       database.get("#{id}/_view/#{view}", options.merge(:key => keys.first))
  #     else
  #       database.post("#{id}/_view/#{view}", { :keys => keys }, options)
  #     end
  #     
  #   rescue DocumentNotFound
  #     # The view document disappeared while we were working with it (maybe the database was recreated).
  #     # Recreate the view.
  #     
  #     @new_record = true
  #     attributes.delete(:_rev)
  #     save!
  #     fetch_result(view, keys, options)
  #   end
  end
end
