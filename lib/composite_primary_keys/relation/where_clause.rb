module ActiveRecord
  class Relation
    class WhereClause
      def to_h(table_name = nil, equality_only: false)
        equalities = equalities(predicates, equality_only)

        # CPK Adds this line, because ours are coming in with AND->{EQUALITY, EQUALITY}
        equalities = predicates.grep(Arel::Nodes::And).map(&:children).flatten.grep(Arel::Nodes::Equality) if equalities.empty?

        equalities.each_with_object({}) do |node, hash|
          next if table_name&.!= node.left.relation.name
          name = node.left.name.to_s
          value = extract_node_value(node.right)
          hash[name] = value
        end
      end
    end
  end
end