module Recliner
  # Recliner automatically timestamps create and update operations if the document has properties
  # named created_at/created_on or updated_at/updated_on.
  module Timestamps#:nodoc:
    extend ActiveSupport::Concern
    
    included do
      [ :save, :save!, :create ].each do |method|
        alias_method_chain method, :timestamps
      end
    end
    
    module ClassMethods
      # Defines timestamp properties created_at and updated_at.
      # When the document is created or updated, these properties will be respectively updated.
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
    
    def save_with_timestamps!(*args)
      write_attribute(:updated_at, Time.now) if properties.include?(:updated_at)
      write_attribute(:updated_on, Time.now) if properties.include?(:updated_on)
      
      save_without_timestamps!(*args)
    end
    
    def create_with_timestamps
      write_attribute(:created_at, Time.now) if properties.include?(:created_at)
      write_attribute(:created_on, Time.now) if properties.include?(:created_on)
      
      create_without_timestamps
    end
  end
end
