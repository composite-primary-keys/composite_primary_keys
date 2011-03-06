module ActiveRecord
  module Persistence
    def cpk_conditions
      if self.composite?
        ids_hash
      else
        self.class.arel_table[self.class.primary_key].eq(id)
      end
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
