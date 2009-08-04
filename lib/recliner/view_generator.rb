module Recliner
  class ViewGenerator
    extend ActiveSupport::Memoizable
    
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def generate
      map = ""
      
      map << "if (#{conditions}) {" unless conditions.blank?
      map << "  emit(#{key}, #{value});"
      map << "}" unless conditions.blank?
      
      [Recliner::MapViewFunction.new(map), nil]
    end
  
  private
    def key
      key = options[:key] || options[:order]
      
      if key.is_a?(Array)
        '[' + key.map { |k| "doc.#{k}" }.join(', ') + ']'
      else
        "doc.#{key}"
      end
    end
    
    def value
      if options[:select]
        "{" + Array(options[:select]).map { |field|
          "\"#{field}\": doc.#{field}"
        }.join(",") + "}"
      else
        'doc'
      end
    end
    
    def conditions
      case options[:conditions]
      when Hash
        conditions = field_conditions(options[:conditions!].merge(options[:conditions]))
      when String
        conditions = field_conditions(options[:conditions!])
        conditions << "(#{options[:conditions]})"
      else
        conditions = field_conditions(options[:conditions!])
      end
      
      conditions.join(' && ')
    end
    
    def field_conditions(conditions)
      conditions.map { |k, v|
        case v
        when true
          "doc.#{k}"
        when false
          "!doc.#{k}"
        else
          "doc.#{k} === #{v.to_json}"
        end
      }
    end
    
    memoize :key, :value, :conditions
  end
end
