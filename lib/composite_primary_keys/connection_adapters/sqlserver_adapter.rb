module ActiveRecord
  module ConnectionAdapters
    class SQLServerAdapter
      def sql_for_insert(sql, pk, id_value, sequence_name, binds)
        sql =
          if pk
            # support composite primary keys consisting of more than one column name
            inserted_pks = [pk].flatten.map {|pk| "inserted.#{pk}"}
            sql.insert(sql.index(/ (DEFAULT )?VALUES/), " OUTPUT #{inserted_pks.join(", ")}")
          else
            "#{sql}; SELECT CAST(SCOPE_IDENTITY() AS bigint) AS Ident"
          end
        [sql, binds]
      end
    end
  end
end
