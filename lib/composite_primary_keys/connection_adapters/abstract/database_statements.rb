module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
        sql, binds = to_sql_and_binds(arel, binds)
        value = exec_insert(sql, name, binds, pk, sequence_name)

        return id_value if id_value

        if pk.is_a?(Array) && !value.empty?
          # This is a CPK model and the query result is not empty. Thus we can figure out the new ids for each
          # auto incremented field
          pk.map {|key| value.first[key]}
        elsif pk.is_a?(Array)
          # This is CPK, but we don't know what autoincremented fields were updated.
          result = Array.new(pk.size)

          # Is there an autoincrementing field?
          auto_key = pk.find do |key|
            attribute = arel.ast.relation[key]
            column = column_for_attribute(attribute)
            if column.respond_to?(:auto_increment?)
              column.auto_increment?
            end
          end

          if auto_key
            result[pk.index(auto_key)] = last_inserted_id(value)
          end
          result
        else
          last_inserted_id(value)
        end
      end
    end
  end
end
