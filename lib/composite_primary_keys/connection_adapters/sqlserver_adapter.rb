module ActiveRecord
  module ConnectionAdapters
    class SQLServerAdapter
      def sql_for_insert(sql, pk, id_value, sequence_name, binds)
        sql = if pk && self.class.use_output_inserted
          # support composite primary keys consisting of more than one column name
          quoted_pks = [pk].flatten.map {|pk| "INSERTED.#{SQLServer::Utils.extract_identifiers(pk).quoted}"}
          sql.insert sql.index(/ (DEFAULT )?VALUES/), " OUTPUT #{quoted_pks.join(", ")}"
#          p sql
        else
          "#{sql}; SELECT CAST(SCOPE_IDENTITY() AS bigint) AS Ident"
        end
        [sql, binds]
      end
        end
      end
end
