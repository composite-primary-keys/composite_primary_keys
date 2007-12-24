require 'active_record/connection_adapters/sqlite_adapter'

module ActiveRecord
  module ConnectionAdapters #:nodoc:
    class SQLite3Adapter < SQLiteAdapter # :nodoc:
      def supports_count_distinct? #:nodoc:
        false
      end
    end
  end
end