module Arel
  module Visitors
    class ToSql
      def visit_Arel_Nodes_In o, collector
        if Array === o.right && o.right.empty?
          collector << '1=0'
        else
          # CPK
          # collector = visit o.left, collector
          if o.left.respond_to?(:name) && o.left.name.is_a?(Array)
=begin
            new_name = o.left.name.each_with_index.map do |field, idx|
              table_name = idx == 0 ? "" : "#{@connection.quote_table_name(o.left.relation.name)}."
              "#{table_name}#{@connection.quote_column_name(field)}"
            end.join(",")

            o.left.name = Arel::Nodes::SqlLiteral.new("#{new_name}")
=end

           if @connection.adapter_name == "SQLite"
            collector << 'EXISTS'
           else
              collector << "("
              collector = visit(o.left, collector)
              collector << ")"
            end
          else
            collector = visit o.left, collector
          end

          collector << " IN" unless @connection.adapter_name == "SQLite"
          collector << " ("
          visit(o.right, collector) << ")"
        end
      end
    end
  end
end
