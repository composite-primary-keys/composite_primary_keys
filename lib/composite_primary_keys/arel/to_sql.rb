module Arel
  module Visitors
    class ToSql
      def visit_Arel_Nodes_In o, collector
        if Array === o.right && o.right.empty?
          collector << '1=0'
        else
          # CPK
          collector << "("
          collector = visit o.left, collector
          # CPK
          collector << ")"
          collector << " IN ("
          visit(o.right, collector) << ")"
        end
      end

      def visit_CompositePrimaryKeys_CompositeKeys o, collector
        values = o.map do |key|
          case key
            when Arel::Attributes::Attribute
              "#{key.relation.name}.#{key.name}"
            else
              key
          end
        end
        collector << "#{values.join(', ')}"
        collector
      end
    end
  end
end
