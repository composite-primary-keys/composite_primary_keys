module ActiveRecord
  class Relation
    def add_cpk_support
      class << self
        include CompositePrimaryKeys::ActiveRecord::Calculations
        include CompositePrimaryKeys::ActiveRecord::FinderMethods
        include CompositePrimaryKeys::ActiveRecord::QueryMethods

        def delete(id_or_array)
          ::ActiveRecord::IdentityMap.remove_by_id(self.symbolized_base_class, id_or_array) if ::ActiveRecord::IdentityMap.enabled?
          # Without CPK:
          # where(primary_key => id_or_array).delete_all

          id_or_array = if id_or_array.kind_of?(CompositePrimaryKeys::CompositeKeys)
            [id_or_array]
          else
            Array(id_or_array)
          end

          id_or_array.each do |id|
            where(cpk_id_predicate(table, self.primary_key, id)).delete_all
          end
        end

        def destroy(id_or_array)
          # Without CPK:
          #if id.is_a?(Array)
          #  id.map { |one_id| destroy(one_id) }
          #else
          #  find(id).destroy
          #end

          id_or_array = if id_or_array.kind_of?(CompositePrimaryKeys::CompositeKeys)
            [id_or_array]
          else
            Array(id_or_array)
          end

          id_or_array.each do |id|
            where(cpk_id_predicate(table, self.primary_key, id)).each do |record|
              record.destroy
            end
          end
        end
      end
    end

    def add_cpk_where_values_hash
      class << self
        def where_values_hash
          # CPK adds this so that it finds the Equality nodes beneath the And node:
          nodes_from_and = with_default_scope.where_values.grep(Arel::Nodes::And).map {|and_node| and_node.children.grep(Arel::Nodes::Equality) }.flatten

          equalities = (nodes_from_and + with_default_scope.where_values.grep(Arel::Nodes::Equality)).find_all { |node|
            node.left.relation.name == table_name
          }

          Hash[equalities.map { |where| [where.left.name, where.right] }]
        end
      end
    end

    alias :initialize_without_cpk :initialize
    def initialize(klass, table)
      initialize_without_cpk(klass, table)
      add_cpk_support if klass.composite?
      add_cpk_where_values_hash
    end

    alias :initialize_copy_without_cpk :initialize_copy
    def initialize_copy(other)
      initialize_copy_without_cpk(other)
      add_cpk_support if klass.composite?
    end
  end
end
