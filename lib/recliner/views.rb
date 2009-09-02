#
# Example views
#
# view :by_title, :order => :title
# view :published, :conditions => { :published => true }
# view :custom_map, :map => "emit(null, doc)"          # function is optional
# view :custom_reduce, :map => "function(doc) { emit(doc.tag, doc); }",
#                      :reduce => "function(keys, values) { return sum(values); }"
#
#
# Overrides default order for 'all' view
#
# default_order :title
#

module Recliner
  module Views
    extend ActiveSupport::Concern
    
    included do
      # view :all
      # 
      # default_order :id
      # default_conditions :class => '#{name}'
    end
    
    module ClassMethods
      def views
        read_inheritable_attribute(:views) || write_inheritable_attribute(:views, {})
      end
      
      #
      #
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

      # #
      # #
      # #
      # def default_order(property=nil)
      #   if property
      #     write_inheritable_attribute(:default_order, properties[property].as)
      #     reset_views!
      #   end
      #   
      #   read_inheritable_attribute(:default_order)
      # end
      # 
      # def default_conditions(conditions=nil)
      #   if conditions
      #     write_inheritable_attribute(:default_conditions, conditions)
      #     reset_views!
      #   end
      #   
      #   read_inheritable_attribute(:default_conditions)
      # end
      # 
      # def count
      #   all.size
      # end
      
      def view_document
        @_view_document ||=
          #ViewDocument.with_database(database) do
            ViewDocument.load(view_document_id) || ViewDocument.new(:id => view_document_id)
          #end
      end
      
      def views_initialized?
        @_views_initialized
      end

      #
      def initialize_views!
        return if views_initialized?
        
        views = self.views.inject({}) do |result, (name, options)|
          #options = { :order => default_order, :conditions! => default_conditions }.merge(options)
          
          result[name] = View.new(interpolate_hash_values(options))
          result
        end
        
        view_document.update_views(views)
        
        views_initialized!
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
