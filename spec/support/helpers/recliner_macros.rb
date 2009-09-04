module ReclinerMacros
  def define_recliner_document(name, parent_class='Recliner::Document', &block)
    before(:each) do
      Object.send(:remove_const, name) if Object.const_defined?(name)
      Object.const_set(name, Class.new(parent_class.constantize))
    
      klass = Object.const_get(name)
      klass.class_eval(&block) if block_given?
      klass
    end
  end
end
