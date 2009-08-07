require File.dirname(__FILE__) + '/view_functions'

module Recliner
  class View
    attr_reader :map, :reduce
    
    def initialize(options={})
      if options[:map]
        @map    = Recliner::MapViewFunction.new(options[:map])
        @reduce = Recliner::ReduceViewFunction.new(options[:reduce]) if options[:reduce]
      else
        @map, @reduce = Recliner::ViewGenerator.new(options).generate
      end
    end
    
    def to_couch
      returning({}) do |result|
        result[:map] = map
        result[:reduce] = reduce if reduce
      end.to_couch
    end
    
    def self.from_couch(hash)
      new(:map => hash['map'], :reduce => hash['reduce'])
    end
    
    def ==(other)
      to_couch.to_json == other.to_couch.to_json
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
        if row['value'].is_a?(Hash) && row['value']['class']
          self.class.instantiate_from_database(row['value'])
        else
          row['value']
        end
      }
    end
    
    def fetch_result(view, keys, options)
      keys = options.delete(:keys) if options[:keys]
      
      case keys.size
      when 0
        database.get("#{id}/_view/#{view}", options)
      when 1
        database.get("#{id}/_view/#{view}", options.merge(:key => keys.first))
      else
        database.post("#{id}/_view/#{view}", { :keys => keys }, options)
      end
      
    rescue DocumentNotFound
      # The view document disappeared while we were working with it (maybe the database was recreated).
      # Recreate the view.
      
      @new_record = true
      attributes.delete(:_rev)
      save!
      fetch_result(view, keys, options)
    end
  end
  
  module Views
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :views
      self.views = {}
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
          write_inheritable_attribute(:default_order, properties[property].as)
          @views_initialized = false
        end
        
        read_inheritable_attribute(:default_order)
      end
      
      def default_conditions(conditions=nil)
        if conditions
          write_inheritable_attribute(:default_conditions, conditions)
          @views_initialized = false
        end
        
        read_inheritable_attribute(:default_conditions)
      end
      
      def count
        all.size
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
      
      def initialize_views!
        return if @views_initialized
        
        update_required = false
        
        views.each do |name, options|
          options = { :order => default_order, :conditions! => default_conditions }.merge(options)
          view = View.new(interpolate_hash_values(options))
          
          if view_document.views[name.to_s] != view
            update_required = true
            view_document.views[name.to_s] = view
          end
        end
        
        view_document.save! if view_document.new_record? || update_required
        
        @views_initialized = true
        
      rescue DocumentNotSaved
        @view_document = nil
        initialize_views!
      end
    end
  end
end
