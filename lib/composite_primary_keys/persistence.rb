module ActiveRecord
  module Persistence
    silence_warnings do
      def relation_for_destroy
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

      def _create_record(attribute_names = self.attribute_names)
        attribute_names &= self.class.column_names
        attributes_values = arel_attributes_with_values_for_create(attribute_names)

        new_id = self.class.unscoped.insert attributes_values

        # CPK
        if self.composite?
          # Merge together the specified id with the new id (specified id gets precedence)
          self.id = self.id.zip(Array(new_id)).map {|id1, id2| (id1.nil? ? id2 : id1)}
        else
          self.id ||= new_id if self.class.primary_key
        end

        @new_record = false

        yield(self) if block_given?

        id
      end
    end
  end
end
