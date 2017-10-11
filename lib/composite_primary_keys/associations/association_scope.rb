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

      def last_chain_scope(scope, table, reflection, owner)
        join_keys = reflection.join_keys
        key = join_keys.key
        foreign_key = join_keys.foreign_key

        # CPK
        #value = transform_value(owner[foreign_key])
        #scope = scope.where(table.name => { key => value })
        mappings = Array(key).zip(Array(foreign_key))
        joins = mappings.reduce(Hash.new) do |hash, mapping|
          hash[mapping.first] = transform_value(owner[mapping.last])
          hash
        end

        if scope.table == table
          scope = scope.where(joins)
        else
          scope = scope.where(table.name => joins)
        end

        if reflection.type
          polymorphic_type = transform_value(owner.class.base_class.name)
          scope = scope.where(table.name => { reflection.type => polymorphic_type })
        end

        scope
      end

      def next_chain_scope(scope, table, reflection, foreign_table, next_reflection)
        join_keys = reflection.join_keys
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
    end
  end
end
