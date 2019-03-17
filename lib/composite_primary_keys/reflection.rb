module ActiveRecord
  module Reflection
    class AbstractReflection
      def join_scope(table, foreign_table, foreign_klass)
        predicate_builder = predicate_builder(table)
        scope_chain_items = join_scopes(table, predicate_builder)
        klass_scope       = klass_join_scope(table, predicate_builder)

        key         = join_keys.key
        foreign_key = join_keys.foreign_key

        # CPK
        #klass_scope.where!(table[key].eq(foreign_table[foreign_key]))
        constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)
        klass_scope.where!(constraint)

        if type
          klass_scope.where!(type => foreign_klass.polymorphic_name)
        end

        if klass.finder_needs_type_condition?
          klass_scope.where!(klass.send(:type_condition, table))
        end

        scope_chain_items.inject(klass_scope, &:merge!)
      end
    end
  end
end
