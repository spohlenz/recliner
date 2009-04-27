module CouchDB
  module Matchers
    class SerializeMatcher
      def initialize(property)
        @property = property
      end
    
      def matches?(owner)
        owner.send("#{@property}=", @value)
        owner.save!
        
        result = owner.class.load(owner.id)
        @actual = result.send(@property)
        
        if @actual.is_a?(Time)
          @actual.to_i == @value.to_i
        else
          @actual == @value
        end
      end
    
      def description
        "serialize #{@property} to #{@value}"
      end
    
      def to(value)
        @value = value
        self
      end
      
      def failure_message_for_should
        message =  "expected CouchDB database to serialize property #{@property} to #{@value.inspect}\n"
        message += "but got #{@actual.inspect}"
      end
      
      def failure_message_for_should_not
        "matcher does not support should_not\n"
      end
    end
    
    def serialize(property)
      SerializeMatcher.new(property)
    end
  end
end
