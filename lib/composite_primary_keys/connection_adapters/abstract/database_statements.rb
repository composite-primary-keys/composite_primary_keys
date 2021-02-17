module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
        sql, binds = to_sql_and_binds(arel, binds)
        value = exec_insert(sql, name, binds, pk, sequence_name)

        if pk.is_a?(Array) && !value.empty?
          # This is a CPK model and the query result is not empty. Thus we can figure out the new ids for each
          # auto incremented field
          id_value || pk.map {|key| value.first[key]}
        elsif pk.is_a?(Array)
          # This is CPK, but we don't know what autoincremented fields were updated. So return nil, which means
          # the existing id_value of the model will be used.
          id_value || Array.new(pk.size)
        else
          id_value || last_inserted_id(value)
        end
      end
    end
  end
end
