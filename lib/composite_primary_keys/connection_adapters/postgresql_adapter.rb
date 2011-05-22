module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
#      # This mightn't be in Core, but count(distinct x,y) doesn't work for me
#      def supports_count_distinct? #:nodoc:
#        false
#      end
#
#      def concat(*columns)
#        columns = columns.map { |c| "CAST(#{c} AS varchar)" }
#        "(#{columns.join('||')})"
#      end

      def quote_column_name(name)
        # CPK
        # PGconn.quote_ident(name.to_s)
        Array(name).map do |col|
          PGconn.quote_ident(col.to_s)
        end.join(CompositePrimaryKeys::ID_SEP)
      end
    end
  end
end
