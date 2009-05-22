module Recliner
  module Validations
    def self.included(base)
      base.alias_method_chain :save, :validations
    end
    
    def valid?
      true
    end
    
    def save_with_validations
      return false unless valid?
      save_without_validations
    end
    private :save_with_validations
  end
end
