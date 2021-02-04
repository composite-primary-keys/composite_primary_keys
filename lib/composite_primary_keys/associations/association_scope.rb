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
          binds << owner.class.polymorphic_name
        end

        chain.each_cons(2).each do |reflection, next_reflection|
          if reflection.type
            binds << next_reflection.klass.polymorphic_name
          end
        end
        binds
      end

      def last_chain_scope(scope, reflection, owner)
        key = reflection.join_primary_key
        foreign_key = reflection.join_foreign_key

        table = reflection.aliased_table

        # CPK
        # value = transform_value(owner[foreign_key])
        # scope = apply_scope(scope, table, key, value)
        Array(key).zip(Array(foreign_key)).each do |a_join_key, a_foreign_key|
          value = transform_value(owner[a_foreign_key])
          scope = apply_scope(scope, table, a_join_key, value)
        end

        if reflection.type
          polymorphic_type = transform_value(owner.class.polymorphic_name)
          scope = apply_scope(scope, table, reflection.type, polymorphic_type)
        end

        scope
      end

      def next_chain_scope(scope, reflection, next_reflection)
        key = reflection.join_primary_key
        foreign_key = reflection.join_foreign_key

        table = reflection.aliased_table
        foreign_table = next_reflection.aliased_table

        # CPK
        # constraint = table[key].eq(foreign_table[foreign_key])
        constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

        if reflection.type
          value = transform_value(next_reflection.klass.polymorphic_name)
          scope = apply_scope(scope, table, reflection.type, value)
        end

        scope.joins!(join(foreign_table, constraint))
      end
    end
  end
end