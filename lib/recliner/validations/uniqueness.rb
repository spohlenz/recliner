module Recliner
  module Validations
    module ClassMethods
      # Validates whether the value of the specified attributes are unique across the system. Useful for making sure that only one user
      # can be named "davidhh".
      #
      #   class Person < Recliner::Document
      #     validates_uniqueness_of :user_name, :scope => :account_id
      #   end
      #
      # It can also validate whether the value of the specified attributes are unique based on multiple scope parameters.  For example,
      # making sure that a teacher can only be on the schedule once per semester for a particular class.
      #
      #   class TeacherSchedule < Recliner::Document
      #     validates_uniqueness_of :teacher_id, :scope => [:semester_id, :class_id]
      #   end
      #
      # When the document is created, a check is performed to make sure that no document exists in the database with the given value for the specified
      # attribute (that maps to a property). When the document is updated, the same check is made but disregarding the document itself.
      #
      # Configuration options:
      # * <tt>:message</tt> - Specifies a custom error message (default is: "has already been taken").
      # * <tt>:scope</tt> - One or more properties by which to limit the scope of the uniqueness constraint.
      # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
      # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>).  The
      #   method, proc or string should return or evaluate to a true or false value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>).  The
      #   method, proc or string should return or evaluate to a true or false value.
      def validates_uniqueness_of(*attr_names)
        configuration = attr_names.extract_options!

        keys = {}

        attr_names.each do |attr_name|
          if configuration[:view]
            keys[attr_name] = views[configuration[:view]][:key]
          else
            keys[attr_name] = [attr_name]
            keys[attr_name] += Array(configuration[:scope]) if configuration[:scope]
            view _validates_uniqueness_of_view_name(keys[attr_name]), :key => keys[attr_name], :select => :_id
          end
        end

        validates_each(attr_names, configuration) do |document, attr_name, value|
          view = configuration[:view] ? configuration[:view] : _validates_uniqueness_of_view_name(keys[attr_name])
          
          if keys[attr_name].is_a?(Array)
            values = keys[attr_name].map { |k| document.read_attribute(k).to_couch }
          else
            values = document.read_attribute(keys[attr_name]).to_couch
          end
          
          ids = send(view, values).map { |result| result['_id'] }
          
          unless ids.empty? || ids.all? { |id| id == document.id }
            document.errors.add(attr_name, :taken, :default => configuration[:message], :value => value)
          end
        end
      end
    
    private
      def _validates_uniqueness_of_view_name(keys)
        :"_by_#{keys.join('_and_')}_for_uniqueness"
      end
    end
  end
end
