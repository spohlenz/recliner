require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/time/conversions'

module Recliner
  class Property < Struct.new(:name, :type, :as, :default)
    TRUE_VALUES = [ true, 1, 'true', 't', 'yes', 'y', '1' ]
    FALSE_VALUES = [ false, 0, 'false', 'f', 'no', 'n', '0' ]
  
    def default_value(instance)
      if default.respond_to?(:call)
        default.arity == 1 ? default.call(instance) : default.call
      else
        default.duplicable? ? default.dup : default
      end
    end
  
    def type_cast(value)
      return nil if value.nil?
    
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
      elsif value.kind_of?(type)
        value
      elsif type.respond_to?(:parse)
        type.parse(value)
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
      if value.is_a?(Time) && RUBY_VERSION < '1.9'
        # Use Ruby 1.9 Time format for consistency
        value.strftime('%Y-%m-%d %T %z')
      else
        value.to_s if value
      end
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
end
