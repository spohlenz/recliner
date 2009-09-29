require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/time/conversions'

module Recliner
  class Property < Struct.new(:name, :type, :as, :default)
    def default_value(instance)
      if default.respond_to?(:call)
        default.arity == 1 ? default.call(instance) : default.call
      else
        default.duplicable? ? default.dup : default
      end
    end
  
    def type_cast(value)
      Conversions.convert(value, type)
    end
  end
end
