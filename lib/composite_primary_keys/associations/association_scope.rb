module ActiveRecord
  module Associations
    class AssociationScope

      def self.get_bind_values(owner, chain)
        binds = []
        last_reflection = chain.last

        # CPK
        # binds << last_reflection.join_id_for(owner)
        values = last_reflection.join_id_for(owner)
        binds += Array(values)

        if last_reflection.type
          binds << owner.class.base_class.name
        end

        chain.each_cons(2).each do |reflection, next_reflection|
          if reflection.type
            binds << next_reflection.klass.base_class.name
          end
        end
        binds
      end

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
          key = Array(key) unless key.kind_of?(Array)
          foreign_key = Array(foreign_key) unless foreign_key.kind_of?(Array)
          key.zip(foreign_key).map do |k, fk|
            bind_val = bind scope, table.table_name, k.to_s, owner[fk], tracker
            scope    = scope.where(table[k].eq(bind_val))
          end
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
