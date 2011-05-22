#require 'active_record/connection_adapters/sqlite3_adapter'
#
#module ActiveRecord
#  module ConnectionAdapters #:nodoc:
#    class SQLite3Adapter # :nodoc:
#      def supports_count_distinct? #:nodoc:
#        false
#      end
#
#      def concat(*columns)
#        "(#{columns.join('||')})"
#      end
#    end
#  end
#end
