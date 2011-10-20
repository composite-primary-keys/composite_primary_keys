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
              key = reflection.association_primary_key(klass)
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

            conditions[i].each do |condition|
              if options[:through] && condition.is_a?(Hash)
                condition = { table.name => condition }
              end

              scope = scope.where(interpolate(condition))
            end
          else
            # CPK
            # constraint = table[key].eq(foreign_table[foreign_key])
            constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)
            scope = scope.where(predicate)

            join       = join(foreign_table, constraint)

            scope = scope.joins(join)

            unless conditions[i].empty?
              scope = scope.where(sanitize(conditions[i], table))
            end
          end
        end

        scope
      end
    end
  end
end
