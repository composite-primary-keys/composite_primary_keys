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
