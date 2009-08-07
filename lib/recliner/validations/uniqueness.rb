module Recliner
  module Validations
    module ClassMethods
      def validates_uniqueness_of(*attr_names)
        configuration = attr_names.extract_options!
        
        keys = {}
        
        attr_names.each do |attr_name|
          keys[attr_name] = [attr_name]
          keys[attr_name] += Array(configuration[:scope]) if configuration[:scope]
          
          view _validates_uniqueness_of_view_name(keys[attr_name]), :key => keys[attr_name], :select => :_id
        end
        
        validates_each(attr_names, configuration) do |document, attr_name, value|
          values = keys[attr_name].map { |k| document.read_attribute(k) }
          ids = send(_validates_uniqueness_of_view_name(keys[attr_name]), values).map { |result| result['_id'] }
          
          unless ids.empty? || ids.all? { |id| id == document.id }
            document.errors.add(attr_name, :taken, :default => configuration[:message], :value => value)
          end
        end
      end
    
    private
      def _validates_uniqueness_of_view_name(keys)
        :"_by_#{keys.join('_and_')}_for_uniqueness"
      end
    end
  end
end
