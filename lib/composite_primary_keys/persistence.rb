module ActiveRecord
  module Persistence
    module ClassMethods
      def delete(id_or_array)
        # CPK
        if self.composite?
          id_or_array = if id_or_array.is_a?(CompositePrimaryKeys::CompositeKeys)
                          [id_or_array]
                        else
                          Array(id_or_array)
                        end

          # Delete should return the number of deleted records
          id_or_array.map do |id|
            # Is the passed in id actually a record?
            id = id.kind_of?(::ActiveRecord::Base) ? id.id : id
            delete_by(cpk_id_predicate(self.arel_table, self.primary_key, id))
          end.sum
        else
          delete_by(primary_key => id_or_array)
        end
      end

      def _update_record(values, constraints) # :nodoc:
        # CPK
        if self.composite? && constraints[primary_key]
          primary_key_values = constraints.delete(primary_key)
          primary_key.each_with_index do |key, i|
           constraints[key] = primary_key_values[i]
          end
        end

        constraints = constraints.map { |name, value| predicate_builder[name, value] }

        default_constraint = build_default_constraint
        constraints << default_constraint if default_constraint

        if current_scope = self.global_current_scope
          constraints << current_scope.where_clause.ast
        end

        um = Arel::UpdateManager.new(arel_table)
        um.set(values.transform_keys { |name| arel_table[name] })
        um.wheres = constraints

        connection.update(um, "#{self} Update")
      end

      def _delete_record(constraints) # :nodoc:
        # CPK
        if self.composite? && constraints[primary_key]
          primary_key_values = constraints.delete(primary_key)
          primary_key.each_with_index do |key, i|
            constraints[key] = primary_key_values[i]
          end
        end

        constraints = constraints.map { |name, value| predicate_builder[name, value] }

        default_constraint = build_default_constraint
        constraints << default_constraint if default_constraint

        if current_scope = self.global_current_scope
          constraints << current_scope.where_clause.ast
        end

        dm = Arel::DeleteManager.new(arel_table)
        dm.wheres = constraints

        connection.delete(dm, "#{self} Destroy")
      end
    end

    def _create_record(attribute_names = self.attribute_names)
      attribute_names = attributes_for_create(attribute_names)

      returning_columns_for_insert = nil

      new_id = self.class._insert_record(
          attributes_with_values(attribute_names),
          returning_columns_for_insert
      )

      # CPK
      if self.composite?
        self.id = self.id.zip(Array(new_id)).map {|id1, id2| id2.nil? ? id1 : id2}
      else
        self.id ||= new_id if self.class.primary_key
      end

      @new_record = false
      @previously_new_record = true

      yield(self) if block_given?

      id
    end
  end
end
