module CompositePrimaryKeys
  module ActiveRecord
    module Persistence
      def relation_for_destroy
        # CPK
        #pk         = self.class.primary_key
        #column     = self.class.columns_hash[pk]
        #substitute = self.class.connection.substitute_at(column, 0)
        #relation = self.class.unscoped.where(
        #  self.class.arel_table[pk].eq(substitute))
        #relation.bind_values = [[column, id]]

        relation = self.class.unscoped

        Array(self.class.primary_key).each_with_index do |key, index|
          column     = self.class.columns_hash[key]
          substitute = self.class.connection.substitute_at(column, index)
          relation = relation.where(self.class.arel_table[key].eq(substitute))
          relation.bind_values += [[column, self[key]]]
        end

        relation
      end

      def touch(name = nil)
        raise ActiveRecordError, "cannot touch on a new record object" unless persisted?

        attributes = timestamp_attributes_for_update_in_model
        attributes << name if name

        unless attributes.empty?
          current_time = current_time_from_proper_timezone
          changes = {}

          attributes.each do |column|
            column = column.to_s
            changes[column] = write_attribute(column, current_time)
          end

          changes[self.class.locking_column] = increment_lock if locking_enabled?

          changed_attributes.except!(*changes.keys)

          relation    = self.class.send(:relation)
          arel_table  = self.class.arel_table
          primary_key = self.class.primary_key

          # CPK
          #self.class.unscoped.where(primary_key => self[primary_key]).update_all(changes) == 1
          primary_key_predicate = relation.cpk_id_predicate(arel_table, Array(primary_key), Array(id))
          self.class.unscoped.where(primary_key_predicate).update_all(changes) == 1
        else
          true
        end
      end

      def _create_record(attribute_names = @attributes.keys)
        attributes_values = arel_attributes_with_values_for_create(attribute_names)

        new_id = self.class.unscoped.insert attributes_values
        self.id ||= new_id if self.class.primary_key

        @new_record = false
        id
      end
    end
  end
end
