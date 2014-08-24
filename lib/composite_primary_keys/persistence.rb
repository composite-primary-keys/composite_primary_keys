module ActiveRecord
  module Persistence
    def relation_for_destroy
      # CPK
      if self.composite?
        relation = self.class.unscoped

        Array(self.class.primary_key).each_with_index do |key, index|
          column     = self.class.columns_hash[key]
          substitute = self.class.connection.substitute_at(column, index)
          relation = relation.where(self.class.arel_table[key].eq(substitute))
          relation.bind_values += [[column, self[key]]]
        end

        relation
      else
        pk         = self.class.primary_key
        column     = self.class.columns_hash[pk]
        substitute = self.class.connection.substitute_at(column, 0)

        relation = self.class.unscoped.where(
          self.class.arel_table[pk].eq(substitute))

        relation.bind_values = [[column, id]]
        relation
      end
    end

    def touch(*names)
      raise ActiveRecordError, "cannot touch on a new record object" unless persisted?

      attributes = timestamp_attributes_for_update_in_model
      attributes.concat(names)

      unless attributes.empty?
        current_time = current_time_from_proper_timezone
        changes = {}

        attributes.each do |column|
          column = column.to_s
          changes[column] = write_attribute(column, current_time)
        end

        changes[self.class.locking_column] = increment_lock if locking_enabled?

        clear_attribute_changes(changes.keys)
        primary_key = self.class.primary_key
        # CPK
        #self.class.unscoped.where(primary_key => self[primary_key]).update_all(changes) == 1
        primary_key_predicate = self.class.unscoped.cpk_id_predicate(self.class.arel_table, Array(primary_key), Array(id))
        self.class.unscoped.where(primary_key_predicate).update_all(changes) == 1
      else
        true
      end
    end
  end
end