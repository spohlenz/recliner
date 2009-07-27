module Recliner
  class DocumentInvalid < StandardError
  end
  
  module Validations
    extend ActiveSupport::Concern
    
    include ActiveModel::Validations
    
    included do
      alias_method_chain :save, :validation
      alias_method_chain :save!, :validation
    end
    
    def save_with_validation
      return false unless valid?
      save_without_validation
    end
    private :save_with_validation
    
    def save_with_validation!
      raise DocumentInvalid unless valid?
      save_without_validation!
    end
    private :save_with_validation!
  end
end
