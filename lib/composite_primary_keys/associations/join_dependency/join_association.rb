module ActiveRecord
  module Associations
    class JoinDependency
      class JoinAssociation
        def build_constraint(reflection, table, key, foreign_table, foreign_key)
          # CPK
          # constraint = table[key].eq(foreign_table[foreign_key])
          constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

          if reflection.klass.finder_needs_type_condition?
            constraint = table.create_and([
              constraint,
              reflection.klass.send(:type_condition, table)
            ])
          end

          constraint
        end
      end
    end
  end
end
