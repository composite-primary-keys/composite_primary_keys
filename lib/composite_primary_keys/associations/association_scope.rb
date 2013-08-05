module ActiveRecord
  module Associations
    class AssociationScope
      def add_constraints(scope)
        tables = construct_tables

        chain.each_with_index do |reflection, i|
          table, foreign_table = tables.shift, tables.first

          if reflection.source_macro == :has_and_belongs_to_many
            join_table = tables.shift

            # CPK
            # scope = scope.joins(join(
            #  join_table,
            #  table[reflection.active_record_primary_key].
            #    eq(join_table[reflection.association_foreign_key])
            #))
            predicate = cpk_join_predicate(table, reflection.association_primary_key,
                                           join_table, reflection.association_foreign_key)
            scope = scope.joins(join(join_table, predicate))

            table, foreign_table = join_table, tables.first
          end

          if reflection.source_macro == :belongs_to
            if reflection.options[:polymorphic]
              key = reflection.association_primary_key(self.klass)
            else
              key = reflection.association_primary_key
            end

            foreign_key = reflection.foreign_key
          else
            key         = reflection.foreign_key
            foreign_key = reflection.active_record_primary_key
          end

          
          if reflection == chain.last
            # CPK
            # scope = scope.where(table[key].eq(owner[foreign_key]))
            predicate = cpk_join_predicate(table, key, owner, foreign_key)
            scope = scope.where(predicate)

            if reflection.type
              scope = scope.where(table[reflection.type].eq(owner.class.base_class.name))
            end
          else
            # CPK
            # constraint = table[key].eq(foreign_table[foreign_key])
            constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

            if reflection.type
              type = chain[i + 1].klass.base_class.name
              constraint = constraint.and(table[reflection.type].eq(type))
            end

            scope = scope.joins(join(foreign_table, constraint))
          end
          
          scope_chain[i].each do |scope_chain_item|
            klass = i == 0 ? self.klass : reflection.klass
            item  = eval_scope(klass, scope_chain_item)

            if scope_chain_item == self.reflection.scope
              scope.merge! item.except(:where, :includes)
            end

            scope.includes! item.includes_values
            scope.where_values += item.where_values
          end
        end

        scope
      end
    end
  end
end
