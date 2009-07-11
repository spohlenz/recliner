require File.dirname(__FILE__) + '/view_functions'

module Recliner
  class View
    attr_reader :map, :reduce
    
    def initialize(options={})
      @map    = Recliner::MapViewFunction.new(options[:map])
      @reduce = Recliner::ReduceViewFunction.new(options[:reduce]) if options[:reduce]
    end
    
    def to_json
      returning({}) do |result|
        result[:map] = map
        result[:reduce] = reduce if reduce
      end.to_json
    end
    
    def ==(other)
      to_json == other.to_json
    end
  end
  
  class ViewDocument < Recliner::Document
    property :language, String, :default => 'javascript'
    property :views, Map(String => View), :default => {}
    
    def invoke(view, *keys)
      options = keys.extract_options!
      fetch(view, keys, options)
    end
  
  private
    def fetch(view, keys, options)
      result = fetch_result(view, keys, options)
      result['rows'].map { |row|
        self.class.instantiate_from_database(row['value'])
      }
    end
    
    def fetch_result(view, keys, options)
      case keys.size
      when 0
        database.get("#{id}/_view/#{view}", options)
      when 1
        database.get("#{id}/_view/#{view}", options.merge(:key => quote_key(keys.first)))
      else
        database.post("#{id}/_view/#{view}", { :keys => keys })
      end
    end
    
    def quote_key(key)
      if key.is_a?(String)
        "\"#{key}\""
      else
        key
      end
    end
  end
  
  module Views
    def self.included(base)
      base.extend(ClassMethods)
      
      base.class_inheritable_accessor :views
      base.views = {}
    end
    
    module ClassMethods
      #
      #
      #
      def view(name, options={})
        views[name] = options
        @views_initialized = false
        
        class_eval <<-END_RUBY
          def self.#{name}(*args)                     # def self.by_name(*args)
            initialize_views!                         #   initialize_views!
            view_document.invoke('#{name}', *args)    #   view_document.invoke('by_name', *args)
          end                                         # end
        END_RUBY
      end
      
      #
      #
      #
      def default_order(property=nil)
        if property
          write_inheritable_attribute(:default_order, "doc.#{properties[property].as}")
          @views_initialized = false
        end
        
        read_inheritable_attribute(:default_order)
      end
      
      def view_document
        @view_document ||= 
          ViewDocument.with_database(database) do
            ViewDocument.load(view_document_id) || ViewDocument.new(:id => view_document_id)
          end
      end
      
      def view_document_id
        "_design/#{name}"
      end
      
      def interpolate(string)
        class_eval("%@#{string.gsub('@', '\@')}@")
      end
      
      def interpolate_hash_values(hash)
        returning(hash.dup) do |result|
          result.each do |key, value|
            result[key] = interpolate(value)
          end
        end
      end
      
      def initialize_views!
        return if @views_initialized
        
        update_required = false
        
        views.each do |name, options|
          view = View.new(interpolate_hash_values(options))
          
          if view_document.views[name.to_s] != view
            update_required = true
            view_document.views[name.to_s] = view
          end
        end
        
        view_document.save! if view_document.new_record? || update_required
        
        @views_initialized = true
      end
    end
  end
end
