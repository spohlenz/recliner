class CallbackTestDocument < Recliner::Document
  class << self
    def callback_string(callback_method)
      "history << [#{callback_method.to_sym.inspect}, :string]"
    end

    def callback_proc(callback_method)
      Proc.new { |model| model.history << [callback_method, :proc] }
    end

    def define_callback_method(callback_method)
      define_method("#{callback_method}_method") do |model|
        model.history << [callback_method, :method]
      end
    end

    def callback_object(callback_method)
      klass = Class.new
      klass.send(:define_method, callback_method) do |model|
        model.history << [callback_method, :object]
      end
      klass.new
    end
  end

  Recliner::Callbacks::CALLBACKS.each do |callback_method|
    callback_method_sym = callback_method.to_sym
    define_callback_method(callback_method_sym)
    send(callback_method, callback_method_sym)
    send(callback_method, callback_string(callback_method_sym))
    send(callback_method, callback_proc(callback_method_sym))
    send(callback_method, callback_object(callback_method_sym))
    send(callback_method) { |model| model.history << [callback_method_sym, :block] }
  end
  
  def history
    @history ||= []
  end
  
  # after_initialize and after_load are invoked only if instance methods have been defined.
  def after_initialize
  end

  def after_load
  end
end
