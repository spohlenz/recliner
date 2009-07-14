module Recliner
  module Associations
    class BelongsToProxy
      alias_method :proxy_respond_to?, :respond_to?
      alias_method :proxy_extend, :extend
      
      delegate :to_param, :to => :proxy_target
      
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }
      
      def initialize(owner, association)
        @owner, @association = owner, association
      end
      
      # Returns the owner of the proxy.
      def proxy_owner
        @owner
      end
      
      # Returns the reflection object that represents the association handled
      # by the proxy.
      def proxy_target
        @target
      end
      
      # Returns the \target of the proxy, same as +target+.
      def proxy_association
        @association
      end
      
      # Has the \target been already \loaded?
      def loaded?
        @loaded
      end
      
      # Asserts the \target has been loaded setting the \loaded flag to +true+.
      def loaded
        @loaded = true
      end
      
      # Returns the target of this proxy, same as +proxy_target+.
      def target
        @target
      end

      # Sets the target of this proxy to <tt>\target</tt>, and the \loaded flag to +true+.
      def target=(target)
        @target = target
        loaded
      end
      
      # Resets the \loaded flag to +false+ and sets the \target to +nil+.
      def reset
        @loaded = false
        @target = nil
      end
      
      # Reloads the \target and returns +self+ on success.
      def reload
        reset
        load_target
        self unless @target.nil?
      end
      
      def inspect
        load_target
        @target.inspect
      end
      
      # Does the proxy or its \target respond to +symbol+?
      def respond_to?(*args)
        proxy_respond_to?(*args) || (load_target && @target.respond_to?(*args))
      end

      # Forwards <tt>===</tt> explicitly to the \target because the instance method
      # removal above doesn't catch it. Loads the \target if needed.
      def ===(other)
        load_target
        other === @target
      end
      
      def send(method, *args)
        if proxy_respond_to?(method)
          super
        else
          load_target
          @target.send(method, *args)
        end
      end
      
    private
      # Forwards any missing method call to the \target.
      def method_missing(method, *args)
        if load_target
          unless @target.respond_to?(method)
            message = "undefined method `#{method.to_s}' for \"#{@target}\":#{@target.class.to_s}"
            raise NoMethodError, message
          end

          if block_given?
            @target.send(method, *args)  { |*block_args| yield(*block_args) }
          else
            @target.send(method, *args)
          end
        end
      end
      
      # Loads the \target if needed and returns it.
      #
      # This method is abstract in the sense that it relies on +find_target+,
      # which is expected to be provided by descendants.
      #
      # If the \target is already \loaded it is just returned. Thus, you can call
      # +load_target+ unconditionally to get the \target.
      #
      # ActiveRecord::RecordNotFound is rescued within the method, and it is
      # not reraised. The proxy is \reset and +nil+ is the return value.
      def load_target
        unless loaded?
          @target = find_target
        end
        
        @loaded = true
        @target
      rescue Recliner::DocumentNotFound
        reset
      end
      
      def find_target
        Recliner::Document.load(@owner.send(@association.property))
      end
    end
    
    class BelongsToAssociation
      attr_reader :name, :options
      
      def initialize(name, options)
        @name, @options = name, options
      end
      
      def generate_code
        <<-END_RUBY
          property :#{property}, String             # property :book_id, String
                                                    #
          def #{name}                               # def book
            associations[:#{name}]                  #   associations[:book]
          end                                       # end
                                                    #
          def #{name}=(obj)                         # def book=(obj)
            self.#{property} = obj.id               #   self.book_id = obj.id
            associations[:#{name}].target = obj     #   associations[:book].target = obj
          end                                       # end
        END_RUBY
      end
      
      def property
        "#{name}_id"
      end
      
      def create_proxy(owner)
        BelongsToProxy.new(owner, self)
      end
    end
  end
end
