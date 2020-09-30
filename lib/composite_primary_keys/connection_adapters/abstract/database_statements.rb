module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
        sql, binds = to_sql_and_binds(arel, binds)
        value = exec_insert(sql, name, binds, pk, sequence_name)

        # CPK
        if !value&.rows&.empty? && pk.is_a?(Array)
          id_value || value.rows.first
        else
          id_value || last_inserted_id(value)
        end
      end
    end
  end
end
