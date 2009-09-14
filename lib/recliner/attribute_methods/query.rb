module Recliner
  module AttributeMethods
    module Query
      extend ActiveSupport::Concern
      
      included do
        attribute_method_suffix "?"
      end
      
      # Returns true if the attribute is not blank (i.e. it has some value). Otherwise returns false.
      def query_attribute(name)
        !read_attribute(name).blank?
      end
      
    private
      # Handle *? for method_missing.
      def attribute?(attribute_name)
        query_attribute(attribute_name)
      end
    end
  end
end
