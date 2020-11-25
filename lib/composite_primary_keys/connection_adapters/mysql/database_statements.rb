# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module MySQL
      module DatabaseStatements
        def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
          sql, binds = to_sql_and_binds(arel, binds)
          value = exec_insert(sql, name, binds, pk, sequence_name)

          # CPK
          if pk.is_a?(Array)
            pk.map do |key|
              column = self.send(:column_for, arel.ast.relation.name, key)
              column.auto_increment? ? last_inserted_id(value) : nil
            end
          else
            id_value || last_inserted_id(value)
          end
        end
      end
    end
  end
end
