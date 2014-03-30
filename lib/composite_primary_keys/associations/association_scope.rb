module ActiveRecord
  module Associations
    class AssociationScope
      def add_constraints(scope, owner, assoc_klass, refl, tracker)
        chain = refl.chain
        scope_chain = refl.scope_chain

        tables = construct_tables(chain, assoc_klass, refl, tracker)

        chain.each_with_index do |reflection, i|
          table, foreign_table = tables.shift, tables.first

          if reflection.source_macro == :belongs_to
            if reflection.options[:polymorphic]
              key = reflection.association_primary_key(assoc_klass)
            else
              key = reflection.association_primary_key
            end

            foreign_key = reflection.foreign_key
          else
            key         = reflection.foreign_key
            foreign_key = reflection.active_record_primary_key
          end

          if reflection == chain.last
            # CPK - TODO add back in tracker support
            #bind_val = bind scope, table.table_name, key.to_s, owner[foreign_key], tracker
            #scope    = scope.where(table[key].eq(bind_val))
            predicate = cpk_join_predicate(table, key, owner, foreign_key)
            scope = scope.where(predicate)

            if reflection.type
              value    = owner.class.base_class.name
              bind_val = bind scope, table.table_name, reflection.type.to_s, value, tracker
              scope    = scope.where(table[reflection.type].eq(bind_val))
            end
          else
            # CPK
            #constraint = table[key].eq(foreign_table[foreign_key])
            constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)

            if reflection.type
              value    = chain[i + 1].klass.base_class.name
              bind_val = bind scope, table.table_name, reflection.type.to_s, value, tracker
              scope    = scope.where(table[reflection.type].eq(bind_val))
            end

            scope = scope.joins(join(foreign_table, constraint))
          end

          is_first_chain = i == 0
          klass = is_first_chain ? assoc_klass : reflection.klass

          # Exclude the scope of the association itself, because that
          # was already merged in the #scope method.
          scope_chain[i].each do |scope_chain_item|
            item  = eval_scope(klass, scope_chain_item, owner)

            if scope_chain_item == refl.scope
              scope.merge! item.except(:where, :includes, :bind)
            end

            if is_first_chain
              scope.includes! item.includes_values
            end

            scope.where_values += item.where_values
            scope.order_values |= item.order_values
          end
        end

        scope
      end
    end
  end
end
