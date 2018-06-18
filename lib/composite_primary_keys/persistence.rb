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

          id_or_array.each do |id|
            # Is the passed in id actually a record?
            id = id.kind_of?(::ActiveRecord::Base) ? id.id : id
            where(cpk_id_predicate(self.arel_table, self.primary_key, id)).delete_all
          end
        else
          where(primary_key => id_or_array).delete_all
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

        constraints = _substitute_values(constraints).map { |attr, bind| attr.eq(bind) }

        um = arel_table.where(
          constraints.reduce(&:and)
        ).compile_update(_substitute_values(values), primary_key)

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

        constraints = _substitute_values(constraints).map { |attr, bind| attr.eq(bind) }

        dm = Arel::DeleteManager.new
        dm.from(arel_table)
        dm.wheres = constraints

        connection.delete(dm, "#{self} Destroy")
      end
    end

    def _relation_for_itself
      # CPK
      if self.composite?
        relation = self.class.unscoped

        Array(self.class.primary_key).each do |key|
          column     = self.class.arel_table[key]
          value      = self[key]
          relation = relation.where(column.eq(value))
        end

        relation
      else
        self.class.unscoped.where(self.class.primary_key => id)
      end
    end

    def touch(*names, time: nil)
      raise ActiveRecordError, "cannot touch on a new record object" unless persisted?

      time ||= current_time_from_proper_timezone
      attributes = timestamp_attributes_for_update_in_model
      attributes.concat(names)

      unless attributes.empty?
        changes = {}

        attributes.each do |column|
          column = column.to_s
          changes[column] = write_attribute(column, time)
        end

        clear_attribute_changes(changes.keys)
        primary_key = self.class.primary_key
        scope = self.class.unscoped.where(primary_key => _read_attribute(primary_key))

        if locking_enabled?
          locking_column = self.class.locking_column
          scope = scope.where(locking_column => _read_attribute(locking_column))
          changes[locking_column] = increment_lock
        end

        # CPK
        if composite?
          primary_key_predicate = self.class.unscoped.cpk_id_predicate(self.class.arel_table, Array(primary_key), Array(id))
          scope = self.class.unscoped.where(primary_key_predicate)
        end

        result = scope.update_all(changes) == 1

        if !result && locking_enabled?
          raise ActiveRecord::StaleObjectError.new(self, "touch")
        end

        result
      else
        true
      end
    end
  end
end
