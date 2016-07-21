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

    def save(*)
      create_or_update
    rescue ActiveRecord::RecordInvalid
      false
    end

    def save!(*)
      create_or_update || raise(RecordNotSaved)
    end

    private

    def create_or_update
      raise ReadOnlyRecord if readonly?
      result = new_record? ? _create_record : _update_record
      result != false
    end

    # Updates the associated record with values matching those of the instance attributes.
    # Returns the number of affected rows.
    def _update_record(attribute_names = @attributes.keys)
      attributes_values = arel_attributes_with_values_for_update(attribute_names)
      if attributes_values.empty?
        0
      else
        self.class.unscoped._update_record attributes_values, id, id_was
      end
    end

    # Creates a record with values matching those of the instance attributes
    # and returns its id.
    def _create_record(attribute_names = @attributes.keys)
      attributes_values = arel_attributes_with_values_for_create(attribute_names)

      new_id = self.class.unscoped.insert attributes_values
      self.id ||= new_id if self.class.primary_key

      # CPK
      if self.class.primary_key && self.id.is_a?(Array) && new_id.is_a?(Array)
        self.id = self.id.map.with_index{|x,i| x or new_id[i]}
      end

      @new_record = false
      id
    end
  end
end