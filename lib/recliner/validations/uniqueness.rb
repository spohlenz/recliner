module Recliner
  module Validations
    module ClassMethods
      def validates_uniqueness_of(*attr_names)
        configuration = attr_names.extract_options!
        
        attr_names.each do |attr_name|
          view :"_by_#{attr_name}_for_uniqueness", :order => attr_name, :select => :_id
        end
        
        validates_each(attr_names, configuration) do |document, attr_name, value|
          ids = send("_by_#{attr_name}_for_uniqueness", value).map { |result| result['_id'] }
          
          unless ids.empty? || ids.all? { |id| id == document.id }
            document.errors.add(attr_name, :taken, :default => configuration[:message], :value => value)
          end
        end
      end
    end
  end
end
