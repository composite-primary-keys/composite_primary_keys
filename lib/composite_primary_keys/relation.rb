module ActiveRecord
  class Relation
    def add_cpk_support
      extend CompositePrimaryKeys::CompositeRelation
    end

    alias :where_values_hash_without_cpk :where_values_hash
    def where_values_hash(relation_table_name = table_name)
      # CPK adds this so that it finds the Equality nodes beneath the And node:
      nodes_from_and = with_default_scope.where_values.grep(Arel::Nodes::And).map {|and_node| and_node.children.grep(Arel::Nodes::Equality) }.flatten

      equalities = (nodes_from_and + with_default_scope.where_values.grep(Arel::Nodes::Equality)).find_all { |node|
        node.left.relation.name == relation_table_name
      }

      Hash[equalities.map { |where| [where.left.name, where.right] }]
    end

    alias :initialize_without_cpk :initialize
    def initialize(klass, table, values = {})
      initialize_without_cpk(klass, table, values)
      add_cpk_support if klass && klass.composite?
    end

    alias :initialize_copy_without_cpk :initialize_copy
    def initialize_copy(other)
      initialize_copy_without_cpk(other)
      add_cpk_support if klass.composite?
    end
  end
end
