module ActiveRecord
  module ConnectionAdapters # :nodoc:
    class AbstractAdapter
      def subquery_need_table_name
        ''
      end
    end
  end
end