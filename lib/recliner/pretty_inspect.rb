module Recliner::Document::PrettyInspect
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def inspect
    "#<#{self.class.name} #{attributes_for_inspect}>"
  end
  
  def attributes_for_inspect
    attrs = self.class.model_properties.map { |name, property| "#{name}: #{send(name).inspect}" }
    attrs.unshift "rev: #{rev}" if rev
    attrs.unshift "id: #{id}"
    attrs * ', '
  end
  
  module ClassMethods
    # Returns a string like 'Post(title:String, body:String)'
    def inspect
      if self == Recliner::Document
        super
      else
        attr_list = model_properties.map { |name, property| "#{name}: #{property.type}" } * ', '
        "#{super}(#{attr_list})"
      end
    end
  end
end
