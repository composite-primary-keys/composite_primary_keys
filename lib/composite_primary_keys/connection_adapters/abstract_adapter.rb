module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def quote_column_names(name)
        Array(name).map do |col|
          quote_column_name(col.to_s)
        end.to_composite_keys.to_s
      end
    end
  end
end