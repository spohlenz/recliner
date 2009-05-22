module Recliner
  module Timestamps
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def timestamps!
        property :created_at, Time
        property :updated_at, Time
        
        before_save { |d| d.updated_at = Time.now }
        before_create { |d| d.created_at = Time.now }
      end
    end
  end
end
