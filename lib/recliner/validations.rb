module Recliner
  class DocumentInvalid < StandardError
  end
  
  module Validations
    def self.included(base)
      base.alias_method_chain :save, :validation
      base.alias_method_chain :save!, :validation
    end
    
    def valid?
      true
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
