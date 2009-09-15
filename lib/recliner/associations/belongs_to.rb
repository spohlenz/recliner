module Recliner
  module Associations
    module BelongsTo
      def belongs_to(name, options={})
        property "#{name}_id", Reference
        
        define_method(name) do
          reference = send("#{name}_id")
          Recliner::Document.with_database(database) { reference.target } if reference
        end
        
        define_method("#{name}=") do |obj|
          reference = send("#{name}_id")
          reference = send("#{name}_id=", Reference.new) unless reference
          reference.replace(obj)
        end
      end
    end
  end
end
