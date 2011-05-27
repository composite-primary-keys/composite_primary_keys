module ActiveRecord
  module Associations
    class Preloader
      class HasAndBelongsToMany
        def records_for(ids)
          # CPK
          #scope = super
          predicate = cpk_in_predicate(join_table, reflection.foreign_key, ids)
          scope = scoped.where(predicate)

          klass.connection.select_all(scope.arel.to_sql, 'SQL', scope.bind_values)
        end

        def join
          # CPK
          #condition = table[reflection.association_primary_key].eq(
           # join_table[reflection.association_foreign_key])
          condition = cpk_join_predicate(table, reflection.association_primary_key,
                                         join_table, reflection.association_foreign_key)

          table.create_join(join_table, table.create_on(condition))
        end

        def association_key_alias(field)
          "ar_association_key_name_#{field.to_s}"
        end

        def join_select
          # CPK
          # association_key.as(Arel.sql(association_key_name))
          Array(reflection.foreign_key).map do |key|
            join_table[key].as(Arel.sql(association_key_alias(key)))
          end
        end

        def association_key_name
          # CPK
          # 'ar_association_key_name'
          Array(reflection.foreign_key).map do |key|
            association_key_alias(key)
          end
        end
      end
    end
  end
end
