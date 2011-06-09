module ActiveRecord
  class Relation
    def add_cpk_support
      class << self
        include CompositePrimaryKeys::ActiveRecord::Calculations
        include CompositePrimaryKeys::ActiveRecord::FinderMethods
        include CompositePrimaryKeys::ActiveRecord::QueryMethods

        def delete(id_or_array)
          ::ActiveRecord::IdentityMap.remove_by_id(self.symbolized_base_class, id_or_array) if ::ActiveRecord::IdentityMap.enabled?
          # CPK
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
          # CPK
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

    alias :initialize_cpk :initialize
    def initialize(klass, table)
      initialize_cpk(klass, table)
      add_cpk_support if klass.composite?
    end

    alias :initialize_copy_cpk :initialize_copy
    def initialize_copy(other)
      initialize_copy_cpk(other)
      add_cpk_support if klass.composite?
    end
  end
end