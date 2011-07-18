module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        # Extract the table from the insert sql. Yuck.
        _, table = extract_schema_and_table(sql.split(" ", 4)[2])

        pk ||= primary_key(table)

        if pk
          # CPK
          # select_value("#{sql} RETURNING #{quote_column_name(pk)}")
          select_value("#{sql} RETURNING #{quote_column_names(pk)}")
        else
          super
        end
      end
      alias :create :insert

      def sql_for_insert(sql, pk, id_value, sequence_name, binds)
        unless pk
          _, table = extract_schema_and_table(sql.split(" ", 4)[2])

          pk = primary_key(table)
        end

        # CPK
        # sql = "#{sql} RETURNING #{quote_column_name(pk)}" if pk
        sql = "#{sql} RETURNING #{quote_column_names(pk)}" if pk

        [sql, binds]
      end
    end
  end
end