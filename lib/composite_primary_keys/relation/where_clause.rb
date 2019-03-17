module ActiveRecord
  class Relation
    class WhereClause
      def to_h(table_name = nil)
        equalities = equalities(predicates)

        # CPK Adds this line, because ours are coming in with AND->{EQUALITY, EQUALITY}
        equalities = predicates.grep(Arel::Nodes::And).map(&:children).flatten.grep(Arel::Nodes::Equality) if equalities.empty?

        if table_name
          equalities = equalities.select do |node|
            node.left.relation.name == table_name
          end
        end

        equalities.map { |node|
          name = node.left.name.to_s
          value = extract_node_value(node.right)
          [name, value]
        }.to_h
      end
    end
  end
end