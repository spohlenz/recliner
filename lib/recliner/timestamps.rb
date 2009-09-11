module Recliner
  module Timestamps
    extend ActiveSupport::Concern
    
    included do
      alias_method_chain :save, :timestamps
      alias_method_chain :create, :timestamps
    end
    
    module ClassMethods
      def timestamps!
        property :created_at, Time
        property :updated_at, Time
      end
    end
    
    def save_with_timestamps(*args)
      write_attribute(:updated_at, Time.now) if properties.include?(:updated_at)
      write_attribute(:updated_on, Time.now) if properties.include?(:updated_on)
      
      save_without_timestamps(*args)
    end
    
    def create_with_timestamps
      write_attribute(:created_at, Time.now) if properties.include?(:created_at)
      write_attribute(:created_on, Time.now) if properties.include?(:created_on)
      
      create_without_timestamps
    end
  end
end
