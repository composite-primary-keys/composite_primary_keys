module ActiveRecord
  module ConnectionAdapters # :nodoc:
    class AbstractAdapter
      def concat(*columns)
        "CONCAT(#{columns.join(',')})"
      end
    end
  end
end
