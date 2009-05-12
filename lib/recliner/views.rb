module Recliner
  class ViewDocument < Recliner::Document
    property :language, String, :default => 'javascript'
    property :views, Hash, :default => {}
  end
  
  module Views
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def view_document
        
      end
    end
  end
end
