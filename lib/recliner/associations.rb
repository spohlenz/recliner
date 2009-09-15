module Recliner
  module Associations
    extend ActiveSupport::Concern
    
    autoload :Reference, 'recliner/associations/reference'
    autoload :BelongsTo, 'recliner/associations/belongs_to'
    
    included do
      extend BelongsTo
    end
  end
end
