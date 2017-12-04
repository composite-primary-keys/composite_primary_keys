module ActiveRecord
  module Reflection
    class AbstractReflection
      def build_join_constraint(table, foreign_table)
        key         = join_keys.key
        foreign_key = join_keys.foreign_key

        # CPK
        #constraint = table[key].eq(foreign_table[foreign_key])
        constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

        if klass.finder_needs_type_condition?
          table.create_and([constraint, klass.send(:type_condition, table)])
        else
          constraint
        end
      end
    end
  end
end
