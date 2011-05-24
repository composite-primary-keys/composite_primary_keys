module CompositePrimaryKeys
  module ActiveRecord
    module Persistence
      def destroy
        if persisted?
          ::ActiveRecord::IdentityMap.remove(self) if ::ActiveRecord::IdentityMap.enabled?

          # CPK
          #pk         = self.class.primary_key
          #column     = self.class.columns_hash[pk]
          #substitute = connection.substitute_at(column, 0)
          bind_values = Array.new
          eq_predicates = Array.new
          self.class.primary_key.each_with_index do |key, i|
            column = self.class.columns_hash[key.to_s]
            bind_values << [column.name, self[key]]
            substitute = connection.substitute_at(column, i)
            eq_predicates << self.class.arel_table[key].eq(substitute)
          end
          predicate = Arel::Nodes::And.new(eq_predicates)
          relation = self.class.unscoped.where(predicate)

          # CPK
          #relation.bind_values = [[column, id]]
          relation.bind_values = bind_values

          relation.delete_all
        end

        @destroyed = true
        freeze
      end

      def update(attribute_names = @attributes.keys)
        attributes_with_values = arel_attributes_values(false, false, attribute_names)
        return 0 if attributes_with_values.empty?
        klass = self.class
        # CPK
        #stmt = klass.unscoped.where(klass.arel_table[klass.primary_key].eq(id)).arel.compile_update(attributes_with_values)
        stmt =  klass.unscoped.where(ids_hash).arel.compile_update(attributes_with_values)
        klass.connection.update stmt.to_sql
      end
    end
  end
end