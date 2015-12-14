module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module Quoting
        def quote_column_name(name)
          # CPK
          # PGconn.quote_ident(name.to_s)
          if name.is_a?(Array)
            name.map do |column|
              PGconn.quote_ident(column.to_s)
            end.join(', ')
          else
            PGconn.quote_ident(name.to_s)
          end
        end
      end
    end
  end
end
