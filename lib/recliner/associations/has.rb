module Recliner
  module Associations
    module Has
      #
      #
      #
      def has(name, options={})
        property "#{name}_id", Reference
        
        class_eval <<-EOF
          def #{name}(force_reload = false)                                   # def user(force_reload = false)
            reference = send("#{name}_id")                                    #   reference = send("user_id")
                                                                              #   
            if reference                                                      #   if reference
              reference.reload if force_reload                                #     reference.reload if force_reload
              Recliner::Document.with_database(database) { reference.target } #     Recliner::Document.with_database(database) { reference.target }
            end                                                               #   end
          end                                                                 # end
                                                                              # 
          def #{name}=(obj)                                                   # def user=(obj)
            reference = send("#{name}_id")                                    #   reference = send("user_id")
            reference = send("#{name}_id=", Reference.new) unless reference   #   reference = send("user_id=", Reference.new) unless reference
            reference.replace(obj)                                            #   reference.replace(obj)
          end                                                                 # end
        EOF
      end
    end
  end
end
