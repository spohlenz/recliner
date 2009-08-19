module ReclinerMacros
  def define_recliner_document(name, &block)
    before(:each) do
      Object.send(:remove_const, name) if Object.const_defined?(name)
      Object.const_set(name, Class.new(Recliner::Document))
    
      klass = Object.const_get(name)
      klass.class_eval(&block) if block_given?
      klass
    end
  end
end
