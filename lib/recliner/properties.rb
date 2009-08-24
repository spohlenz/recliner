require 'uuid'

module Recliner
  class Property < Struct.new(:name, :type, :as, :default)
    TRUE_VALUES = [ true, 1, 'true', 't', 'yes', 'y', '1' ]
    FALSE_VALUES = [ false, 0, 'false', 'f', 'no', 'n', '0' ]
    
    def default_value(instance)
      default.respond_to?(:call) ? default.call(instance) : default
    end
    
    def type_cast(value)
      if type == Date
        convert_to_date(value)
      elsif type == Time
        convert_to_time(value)
      elsif type == Boolean
        convert_to_boolean(value)
      elsif type == String
        convert_to_string(value)
      elsif type == Integer
        convert_to_integer(value)
      elsif type == Float
        convert_to_float(value)
      else
        value
      end
    end
  
  private
    def convert_to_boolean(value)
      value.downcase! if value.is_a?(String)
      
      if TRUE_VALUES.include?(value)
        true
      elsif FALSE_VALUES.include?(value)
        false
      else
        nil
      end
    end
    
    def convert_to_string(value)
      value.to_s if value
    end
    
    def convert_to_integer(value)
      if value
        result = value.to_i
        
        # string.to_i returns 0 if the string does not contain a number - we want nil
        result = nil if result == 0 && value.is_a?(String) && value !~ /^\s*\d/
        
        result
      end
    end
    
    def convert_to_float(value)
      if value
        result = value.to_f
      
        # string.to_f returns 0 if the string does not contain a number - we want nil
        result = nil if result == 0.0 && value.is_a?(String) && value !~ /^\s*[\d\.]/
        
        result
      end
    end
  
    def convert_to_date(value)
      case value
      when String         then parse_date(value)
      when Time, DateTime then value.to_date
      when Date           then value
      else nil
      end
    end
    
    def convert_to_time(value)
      case value
      when String then parse_time(value)
      when Date   then value.to_time
      when Time   then value
      else nil
      end
    end
    
    def parse_time(value)
      parts = Date._parse(value)
      Time.time_with_datetime_fallback(:local, parts[:year], parts[:mon], parts[:mday], parts[:hour], parts[:min], parts[:sec]) rescue nil
    end
    
    def parse_date(value)
      parts = Date._parse(value)
      Date.new(parts[:year], parts[:mon], parts[:mday]) rescue nil
    end
  end
  
  module Properties
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :properties
      self.properties = ActiveSupport::OrderedHash.new
      
      property :id,  String, :as => '_id', :default => lambda { generate_guid }
      property :rev, String, :as => '_rev'
    end
    
    module ClassMethods
      #
      def property(name, *args, &block)
        options = args.extract_options!
        type = args.first
        
        if type
          prop = Property.new(name.to_s, type, (options[:as] || name).to_s, options[:default])
          properties[name.to_sym] = prop
      #   elsif block_given?
      #     raise 'Not yet supported'
        else
          raise ArgumentError.new('Either a type or block must be provided')
        end
      end
      
      # Returns all defined properties except for id and rev
      def model_properties
        properties.reject { |name, property| [:id, :rev].include?(name) }
      end
      
    protected
      # Unique ID generation for new documents
      def generate_guid
        UUID.generate
      end
    end
    
  private
    def property(name)
      properties[name.to_sym]
    end
  end
end
