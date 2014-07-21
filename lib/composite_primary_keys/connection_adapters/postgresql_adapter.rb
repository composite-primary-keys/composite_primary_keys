module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        unless pk
          # Extract the table from the insert sql. Yuck.
          table_ref = extract_table_ref_from_insert_sql(sql)
          pk = primary_key(table_ref) if table_ref
        end

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
          # Extract the table from the insert sql. Yuck.
          table_ref = extract_table_ref_from_insert_sql(sql)
          pk = primary_key(table_ref) if table_ref
        end

        # CPK
        # sql = "#{sql} RETURNING #{quote_column_name(pk)}" if pk
        sql = "#{sql} RETURNING #{quote_column_names(pk)}" if pk

        [sql, binds]
      end

      # Returns a single value if query returns a single element
      # otherwise returns an array coresponding to the composite keys
      #
      def last_inserted_id(result)
        row = result && result.rows.first
        if Array === row
          row.size == 1 ? row[0] : row
        end
      end
    end
  end
end
