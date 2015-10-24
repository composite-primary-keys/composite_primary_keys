module ActiveRecord
  module Associations
    class AssociationScope

      def next_chain_scope(scope, table, reflection, tracker, assoc_klass, foreign_table, next_reflection)
        join_keys = reflection.join_keys(assoc_klass)
        key = join_keys.key
        foreign_key = join_keys.foreign_key

        # CPK
        # constraint = table[key].eq(foreign_table[foreign_key])
        constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

        if reflection.type
          value    = next_reflection.klass.base_class.name
          bind_val = bind scope, table.table_name, reflection.type, value, tracker
          scope    = scope.where(table[reflection.type].eq(bind_val))
        end

        scope.joins(join(foreign_table, constraint))
      end

      def last_chain_scope(scope, table, reflection, owner, tracker, assoc_klass)
        join_keys = reflection.join_keys(assoc_klass)
        key = join_keys.key
        foreign_key = join_keys.foreign_key

        if key.kind_of?(Array) || foreign_key.kind_of?(Array)
          predicate = cpk_join_predicate(table, key, owner, foreign_key)
          scope = scope.where(predicate)
        else
          bind_val = bind scope, table.table_name, key.to_s, owner[foreign_key], tracker
          scope    = scope.where(table[key].eq(bind_val))
        end

        if reflection.type
          value    = owner.class.base_class.name
          bind_val = bind scope, table.table_name, reflection.type, value, tracker

          scope.where(table[reflection.type].eq(bind_val))
        else
          scope
        end
      end
    end
  end
end
