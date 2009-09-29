module Recliner
  module Conversions
    extend self
    
    class ConversionError < TypeError
    end
    
    def clear!
      conversions.clear
    end
    
    def convert(from, to, options={})
      return nil if from.nil?
      return from if to.is_a?(Class) && from.kind_of?(to)
      
      source = options[:source] || from.class
      
      if block = conversion(source, to)
        from.instance_eval(&block) rescue nil
      else
        raise ConversionError, "No registered conversion from #{source} to #{to.inspect}"
      end
    end
    
    def convert!(from, to, options={})
      return nil if from.nil?
      return from if to.is_a?(Class) && from.kind_of?(to)
      
      source = options[:source] || from.class
      
      if block = conversion(source, to)
        begin
          from.instance_eval(&block)
        rescue => e
          raise ConversionError, "Conversion block raised exception"
        end
      else
        raise ConversionError, "No registered conversion from #{source} to #{to.inspect}"
      end
    end
    
    def register(from, to, &block)
      conversions[from][to] = block
    end
    
  private
    def conversion(from, to)
      while from
        return conversions[from][to] if conversions[from] && conversions[from][to]
        from = from.is_a?(Class) ? from.superclass : nil
      end
      nil
    end
  
    def conversions
      @conversions ||= Hash.new { |hash, key| hash[key] = {} }
    end
  end
end

Dir[File.dirname(__FILE__) + "/conversions/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "recliner/conversions/#{filename}"
end
