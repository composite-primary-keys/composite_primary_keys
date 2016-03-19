module ActiveRecord
  module Associations
    class AssociationScope

      def next_chain_scope(scope, table, reflection, association_klass, foreign_table, next_reflection)
        join_keys = reflection.join_keys(association_klass)
        key = join_keys.key
        foreign_key = join_keys.foreign_key
        # CPK
        # constraint = table[key].eq(foreign_table[foreign_key])
        constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

        if reflection.type
          value = transform_value(next_reflection.klass.base_class.name)
          scope = scope.where(table.name => { reflection.type => value })
        end

        scope = scope.joins(join(foreign_table, constraint))
      end

      def last_chain_scope(scope, table, reflection, owner, association_klass)
        join_keys = reflection.join_keys(association_klass)
        key = join_keys.key
        foreign_key = join_keys.foreign_key

        # CPK
        if key.kind_of?(Array) || foreign_key.kind_of?(Array)
          predicate = cpk_join_predicate(table, key, owner, foreign_key)
          scope = scope.where(predicate)
        else
          value = transform_value(owner[foreign_key])
          scope = scope.where(table.name => { key => value })
        end

        if reflection.type
          polymorphic_type = transform_value(owner.class.base_class.name)
          scope = scope.where(table.name => { reflection.type => polymorphic_type })
        end

        scope
      end
    end
  end
end
