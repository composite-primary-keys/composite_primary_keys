module ActiveRecord
  class Relation

    alias :where_values_hash_without_cpk :where_values_hash
    def where_values_hash
      # CPK adds this so that it finds the Equality nodes beneath the And node:
      nodes_from_and = with_default_scope.where_values.grep(Arel::Nodes::And).map {|and_node| and_node.children.grep(Arel::Nodes::Equality) }.flatten

      equalities = (nodes_from_and + with_default_scope.where_values.grep(Arel::Nodes::Equality)).find_all { |node|
        node.left.relation.name == table_name
      }

      Hash[equalities.map { |where| [where.left.name, where.right] }]
    end

    class << self
      alias :new_without_cpk :new
      def new(klass, table, &block)
        obj = relation_class(klass && klass.composite?).allocate
        obj.send :initialize, klass, table, &block
        obj
      end

      private

      def relation_class(composite)
        if composite
          CompositePrimaryKeys::CompositeRelation
        else
          ActiveRecord::Relation
        end
      end
    end
  end
end
