module Arel
  module Visitors
    class ToSql
      def visit_Arel_Nodes_In o, a
        if Array === o.right && o.right.empty?
          '1=0'
        else
          a = o.left if Arel::Attributes::Attribute === o.left
          # CPK
          #"#{visit o.left, a} IN (#{visit o.right, a})"
          if o.left.name.is_a?(Array)
          "(#{visit o.left, a}) IN (#{visit o.right, a})"
          else
            "#{visit o.left, a} IN (#{visit o.right, a})"
          end
        end
      end
    end
  end
end
