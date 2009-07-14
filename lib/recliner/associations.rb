module Recliner
  module Associations
    autoload :BelongsTo, 'recliner/associations/belongs_to'
    
    def self.included(base)
      base.extend(ClassMethods)
      
      base.extend(BelongsTo::ClassMethods)
    end
    
    module ClassMethods
      def associations
        read_inheritable_attribute(:associations) || write_inheritable_attribute(:associations, {})
      end
    end
    
    def associations
      @associations ||= initialize_associations
    end
    
  private
    def initialize_associations
      self.class.associations.inject({}) { |result, name_and_association|
        name, association = name_and_association
        
        result[name] = association.create_proxy(self)
        result
      }
    end
  end
end
