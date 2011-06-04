module CompositePrimaryKeys
  module ActiveRecord
    module NamedScope
      module ClassMethods
        def scoped(options = nil)
          result = if options
            scoped.apply_finder_options(options)
          else
            if current_scope
              current_scope.clone
            else
              scope = relation.clone
              scope.default_scoped = true
              scope
            end
          end

          # CPK
          class << result
            include CompositePrimaryKeys::ActiveRecord::Calculations
            include CompositePrimaryKeys::ActiveRecord::FinderMethods
            include CompositePrimaryKeys::ActiveRecord::QueryMethods
            include CompositePrimaryKeys::ActiveRecord::Relation
          end
          result
        end
      end
    end
  end
end