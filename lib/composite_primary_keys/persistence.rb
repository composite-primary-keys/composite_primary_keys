module ActiveRecord
  module Persistence
    def cpk_conditions
      if self.composite?
        ids_hash
      else
        self.class.arel_table[self.class.primary_key].eq(id)
      end
    end

    def create
      if self.id.nil? && connection.prefetch_primary_key?(self.class.table_name)
        self.id = connection.next_sequence_value(self.class.sequence_name)
      end

      attributes_values = arel_attributes_values

      new_id = if attributes_values.empty?
        self.class.unscoped.insert connection.empty_insert_statement_value
      else
        self.class.unscoped.insert attributes_values
      end

      # CPK
      # self.id ||= new_id
      self[:id] ||= new_id

      @new_record = false
      id
    end

    def destroy
      if persisted?
        # self.class.unscoped.where(self.class.arel_table[self.class.primary_key].eq(id)).delete_all
        self.class.unscoped.where(cpk_conditions).delete_all
      end

      @destroyed = true
      freeze
    end

    def update(attribute_names = @attributes.keys)
      attributes_with_values = arel_attributes_values(false, false, attribute_names)
      return 0 if attributes_with_values.empty?
      # CPK
      # self.class.unscoped.where(self.class.arel_table[self.class.primary_key].eq(id)).arel.update(attributes_with_values)
      self.class.unscoped.where(cpk_conditions).arel.update(attributes_with_values)
    end
  end
end
