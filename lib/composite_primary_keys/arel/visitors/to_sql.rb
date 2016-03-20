module Arel
  module Visitors
    class ToSql
      def visit_Arel_Attributes_Attribute o, collector
        join_name = o.relation.table_alias || o.relation.name
        table_name = quote_table_name join_name

        if o.name.is_a? Array
          collector <<
            o.name.map{ |field| "#{table_name}.#{quote_column_name(field)}" }.join(",")
        else
          collector << "#{table_name}.#{quote_column_name o.name}"
        end
      end

      def visit_Arel_Nodes_In o, collector
        if Array === o.right && o.right.empty?
          collector << '1=0'
        else
          # CPK
          # collector = visit o.left, collector
          if o.left.respond_to?(:name) && o.left.name.is_a?(Array)
            collector << "("
            collector = visit(o.left, collector)
            collector << ")"
          else
            collector = visit o.left, collector
          end

          collector << " IN ("
          visit(o.right, collector) << ")"
        end
      end
    end
  end
end
