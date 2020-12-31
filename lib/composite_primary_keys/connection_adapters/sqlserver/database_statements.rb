module ActiveRecord
  module ConnectionAdapters
    module SQLServer
      module DatabaseStatements
        def sql_for_insert(sql, pk, binds)
          if pk.nil?
            table_name = query_requires_identity_insert?(sql)
            pk = primary_key(table_name)
          end

          sql = if pk && use_output_inserted? && !database_prefix_remote_server?
                  # CPK
                  #quoted_pk = SQLServer::Utils.extract_identifiers(pk).quoted
                  quoted_pk = Array(pk).map {|subkey| SQLServer::Utils.extract_identifiers(subkey).quoted}

                  table_name ||= get_table_name(sql)
                  exclude_output_inserted = exclude_output_inserted_table_name?(table_name, sql)
                  if exclude_output_inserted
                    id_sql_type = exclude_output_inserted.is_a?(TrueClass) ? "bigint" : exclude_output_inserted
                    # CPK
                    # <<~SQL.squish
                    #   DECLARE @ssaIdInsertTable table (#{quoted_pk} #{id_sql_type});
                    #   #{sql.dup.insert sql.index(/ (DEFAULT )?VALUES/), " OUTPUT INSERTED.#{quoted_pk} INTO @ssaIdInsertTable"}
                    #   SELECT CAST(#{quoted_pk.join(',')} AS #{id_sql_type}) FROM @ssaIdInsertTable
                    # SQL
                    <<~SQL.squish
                      DECLARE @ssaIdInsertTable table (#{quoted_pk.map {|subkey| "#{subkey} #{id_sql_type}"}.join(", ")});
                      #{sql.dup.insert sql.index(/ (DEFAULT )?VALUES/), " OUTPUT INSERTED.#{quoted_pk.join(', INSERTED.')} INTO @ssaIdInsertTable"}
                      SELECT #{quoted_pk.map {|subkey| "CAST(#{subkey} AS #{id_sql_type}) #{subkey}"}.join(", ")} FROM @ssaIdInsertTable
                    SQL
                  else
                    # CPK
                    # sql.dup.insert sql.index(/ (DEFAULT )?VALUES/), " OUTPUT INSERTED.#{quoted_pk}"
                    sql.dup.insert sql.index(/ (DEFAULT )?VALUES/), " OUTPUT INSERTED.#{quoted_pk.join(', INSERTED.')}"
                  end
                else
                  "#{sql}; SELECT CAST(SCOPE_IDENTITY() AS bigint) AS Ident"
                end
          super
        end
      end
    end
  end
end
