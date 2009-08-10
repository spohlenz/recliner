module Recliner
  module AttributeMethods
    module Dirty
      extend ActiveSupport::Concern
      
      DIRTY_AFFIXES = [
        { :suffix => '_changed?' },
        { :suffix => '_change' }#,
        # { :suffix => '_will_change!' },
        # { :suffix => '_was' },
        # { :prefix => 'reset_', :suffix => '!' }
      ]

      included do
        attribute_method_affix *DIRTY_AFFIXES
        
        alias_method_chain :save,  :dirty
        alias_method_chain :save!, :dirty
      end
      
      # Do any attributes have unsaved changes?
      #   person.changed? # => false
      #   person.name = 'bob'
      #   person.changed? # => true
      def changed?
        !changed_attributes.empty?
      end
      
      # List of attributes with unsaved changes.
      #   person.changed # => []
      #   person.name = 'bob'
      #   person.changed # => ['name']
      def changed
        changed_attributes.keys
      end
      
      # Map of changed attrs => [original value, new value].
      #   person.changes # => {}
      #   person.name = 'bob'
      #   person.changes # => { 'name' => ['bill', 'bob'] }
      def changes
        changed.inject({}) { |h, attr| h[attr] = attribute_change(attr); h }
      end
      
      # Attempts to +save+ the record and clears changed attributes if successful.
      def save_with_dirty(*args) #:nodoc:
        if status = save_without_dirty(*args)
          changed_attributes.clear
        end
        status
      end

      # Attempts to <tt>save!</tt> the record and clears changed attributes if successful.
      def save_with_dirty!(*args) #:nodoc:
        status = save_without_dirty!(*args)
        changed_attributes.clear
        status
      end
      
    private
      # Map of change <tt>attr => original value</tt>.
      def changed_attributes
        @changed_attributes ||= {}
      end
      
      # Handle <tt>*_changed?</tt> for +method_missing+.
      def attribute_changed?(attr)
        changed_attributes.include?(attr)
      end
      
      # Handle <tt>*_change</tt> for +method_missing+.
      def attribute_change(attr)
        [changed_attributes[attr], __send__(attr)] if attribute_changed?(attr)
      end
      
      # Wrap write_attribute to remember original attribute value.
      def write_attribute(attr, value)
        attr = attr.to_s

        # The attribute already has an unsaved change.
        if changed_attributes.include?(attr)
          old = changed_attributes[attr]
          changed_attributes.delete(attr) if value == old
        else
          old = clone_attribute_value(:read_attribute, attr)
          changed_attributes[attr] = old unless value == old
        end

        # Carry on.
        super(attr, value)
      end
    end
  end
end
