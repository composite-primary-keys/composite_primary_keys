module CompositePrimaryKeys
  module ActiveRecord
    module Persistence
      def relation_for_destroy
        return super unless composite?
        
        where_hash = {}
        primary_keys = Array(self.class.primary_key)

        primary_keys.each do |key|
          where_hash[key.to_s] = self[key]
        end

        relation = self.class.unscoped.where(where_hash)
      end
      

      def touch(name = nil)
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

          @changed_attributes.except!(*changes.keys)

          relation    = self.class.send(:relation)
          arel_table  = self.class.arel_table
          primary_key = self.class.primary_key

          primary_key_predicate = relation.cpk_id_predicate(arel_table, Array(primary_key), Array(id))

          self.class.unscoped.where(primary_key_predicate).update_all(changes) == 1
        end
      end

      def update_record(attribute_names = @attributes.keys)
        return super(attribute_names) unless composite?
        
        klass = self.class
        
        attributes_with_values = arel_attributes_with_values_for_update(attribute_names)
        return 0 if attributes_with_values.empty?

        if !can_change_primary_key? and primary_key_changed?
          raise ActiveRecord::CompositeKeyError, "Cannot update primary key values without ActiveModel::Dirty"
        elsif primary_key_changed?
          stmt = klass.unscoped.where(primary_key_was).arel.compile_update(attributes_with_values)
        else
          stmt = klass.unscoped.where(ids_hash).arel.compile_update(attributes_with_values)
        end
        
        klass.connection.update stmt.to_sql
      end
    end
  end
end
