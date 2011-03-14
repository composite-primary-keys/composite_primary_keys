module Arel
  module Nodes
    class SubSelect < Node
      attr_accessor :select, :as

      def initialize(select, as = 'subquery')
        @select = select
        @as = as
      end
    end
  end

  module Visitors
    class ToSql
      def visit_Arel_Nodes_SubSelect o
        "(#{visit(o.select)}) AS #{o.as}"
      end
    end
  end

  class SelectManager
    def from table, as = nil
      table = case table
        when Arel::SelectManager
          Nodes::SubSelect.new(table.ast, as)
        when String
          Nodes::SqlLiteral.new(table)
        else
          table
        end

      # FIXME: this is a hack to support
      # test_with_two_tables_in_from_without_getting_double_quoted
      # from the AR tests.
      if @ctx.froms
        source = @ctx.froms

        if Nodes::SqlLiteral === table && Nodes::Join === source
          source.left = table
          table = source
        end
      end
      @ctx.froms = table
      self
    end
  end
end