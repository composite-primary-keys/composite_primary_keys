module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
        value = exec_insert(to_sql(arel, binds), name, binds, pk, sequence_name)

        # CPK
        if value && pk.is_a?(Array)
          id_value || value.rows.first
        else
          id_value || last_inserted_id(value)
        end
      end
    end
  end
end
