module Recliner
  #
  # Example views
  #
  #   view :by_title, :order => :title
  #   view :published, :conditions => { :published => true }
  #   view :custom_map, :map => "emit(null, doc)"          # function is optional
  #   view :custom_reduce, :map => "function(doc) { emit(doc.tag, doc); }",
  #                      :reduce => "function(keys, values) { return sum(values); }"
  #
  module Views
    extend ActiveSupport::Concern
    
    included do
      view :all
      
      default_order :id
      default_conditions :class => '#{name}'
    end
    
    module ClassMethods
      # Returns hash of all the views that have been defined for this document type and parent document types.
      def views
        read_inheritable_attribute(:views) || write_inheritable_attribute(:views, {})
      end
      
      #
      def view(name, options={})
        views[name] = options
        reset_views!

        class_eval <<-END_RUBY
          def self.#{name}(*args)                     # def self.by_name(*args)
            initialize_views!                         #   initialize_views!
            view_document.invoke('#{name}', *args)    #   view_document.invoke('by_name', *args)
          end                                         # end
        END_RUBY
      end

      # Sets or gets the default view order for this document type.
      #
      # When setting, +attribute+ should be the property name.
      def default_order(attribute=nil)
        if attribute
          property = properties[attribute.to_sym]
          
          write_inheritable_attribute(:default_order, property ? property.as : attribute)
          reset_views!
        end
        
        read_inheritable_attribute(:default_order)
      end
      
      # Sets or gets the default view conditions for this document type.
      #
      # When setting, +conditions+ may be either a String or a Hash.
      # Using a Hash is recommended as it will allow subclasses to specify
      # further conditions by using:
      #
      #   default_conditions.merge!({ :override => 'conditions' })
      def default_conditions(conditions=nil)
        if conditions
          write_inheritable_attribute(:default_conditions, conditions)
          reset_views!
        end
        
        read_inheritable_attribute(:default_conditions)
      end
      
      # Returns the view design document for this document type.
      # If it doesn't already exist, a new view document will be created.
      def view_document
        @_view_document ||=
          ViewDocument.with_database(database) do
            ViewDocument.load(view_document_id) || ViewDocument.new(:id => view_document_id)
          end
      end
      
      # Returns true if the views for this document type have been initialized; otherwise returns false.
      def views_initialized?
        @_views_initialized
      end

      # Initializes the views for this document type by synchronizing with the CouchDB view document.
      def initialize_views!
        return if views_initialized?
        
        views = self.views.inject({}) do |result, (name, options)|
          options = { :order => default_order, :conditions! => default_conditions }.merge(options)
          
          result[name] = View.new(interpolate_hash_values(options))
          result
        end
        
        view_document.update_views(views)
        
        views_initialized!
      end
      
      #
      def first
        all(:limit => 1).first
      end
      
      #
      def last
        all(:limit => 1, :descending => true).first
      end
      
      #
      def count
        all.size
      end
    
    private
      def view_document_id
        "_design/#{name}"
      end
    
      def views_initialized!
        @_views_initialized = true
      end
      
      def interpolate(string)
        class_eval("%@#{string.gsub('@', '\@')}@")
      end
      
      def interpolate_hash_values(hash)
        returning(hash.dup) do |result|
          result.each do |key, value|
            result[key] = case value
            when String
              interpolate(value)
            when Hash
              interpolate_hash_values(value)
            else
              value
            end
          end
        end
      end
      
      def reset_views!
        @_views_initialized = false
      end
    end
  end
end
