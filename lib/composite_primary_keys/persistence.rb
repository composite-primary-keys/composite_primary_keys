module ActiveRecord
  module Persistence
    def destroy
      destroy_associations

      if persisted?
        IdentityMap.remove(self) if IdentityMap.enabled?
        # CPK
        #pk         = self.class.primary_key
        #column     = self.class.columns_hash[pk]
        #substitute = connection.substitute_at(column, 0)

        where_hash = {}
        primary_keys = Array(self.class.primary_key)

        #relation = self.class.unscoped.where(
        #  self.class.arel_table[pk].eq(substitute))

        primary_keys.each do |key|
          where_hash[key.to_s] = self[key]
        end

        # CPK      
        #relation.bind_values = [[column, id]]

        relation = self.class.unscoped.where(where_hash)
        relation.delete_all
      end

      @destroyed = true
      freeze
    end

    def update(attribute_names = @attributes.keys)
      klass = self.class
      if !self.composite?
        attributes_with_values = arel_attributes_values(false, false, attribute_names)
        return 0 if attributes_with_values.empty?
        stmt = klass.unscoped.where(klass.arel_table[klass.primary_key].eq(id)).arel.compile_update(attributes_with_values)
      else
        attributes_with_values = arel_attributes_values(can_change_primary_key?, false, attribute_names)
        return 0 if attributes_with_values.empty?

        if !can_change_primary_key? and primary_key_changed?
          raise ActiveRecord::CompositeKeyError, "Cannot update primary key values without ActiveModel::Dirty"
        elsif primary_key_changed?
          stmt = klass.unscoped.where(primary_key_was).arel.compile_update(attributes_with_values)
        else
          stmt = klass.unscoped.where(ids_hash).arel.compile_update(attributes_with_values)
        end
      end
      klass.connection.update stmt.to_sql
    end
  end
end