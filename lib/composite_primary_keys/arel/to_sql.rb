module Arel
  module Visitors
    class ToSql
      def visit_CompositePrimaryKeys_CompositeKeys o, collector
        values = o.map do |key|
          case key
            when Arel::Attributes::Attribute
              "#{quote_table_name(key.relation.name)}.#{quote_column_name(key.name)}"
            else
              quote_column_name(key)
          end
        end
        collector << "(#{values.join(', ')})"
        collector
      end
    end
  end
end
