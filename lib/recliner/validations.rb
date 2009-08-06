module Recliner
  class DocumentInvalid < StandardError
    attr_reader :document
    
    def initialize(document)
      @document = document
      super("Validation failed: #{@document.errors.full_messages.join(", ")}")
    end
  end
  
  module Validations
    extend ActiveSupport::Concern
    
    include ActiveModel::Validations
    
    included do
      alias_method_chain :save, :validation
      alias_method_chain :save!, :validation
      
      define_callbacks :validate_on_create, :validate_on_update
    end
    
    module ClassMethods
      def validation_method(on)
        case on
        when :create
          :validate_on_create
        when :update
          :validate_on_update
        else
          :validate
        end
      end
    end
    
    def save_with_validation
      if valid?
        save_without_validation
      else
        false
      end
    end
    
    def save_with_validation!
      if valid?
        save_without_validation!
      else
        raise DocumentInvalid.new(self)
      end
    end
    
    # Runs all the specified validations and returns true if no errors were added otherwise false.
    def valid?
      errors.clear

      run_callbacks(:validate)

      if new_record?
        run_callbacks(:validate_on_create)
      else
        run_callbacks(:validate_on_update)
      end

      errors.empty?
    end
  end
end
