module CompositePrimaryKeys
  module ActiveRecord
    module Persistence
      def relation_for_destroy
        return super unless composite?
        
        where_hash = {}
        primary_keys = Array(self.class.primary_key)

        if primary_keys.empty?
          raise ActiveRecord::CompositeKeyError, "No primary key(s) defined for #{self.class.name}"
        end

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

      # FIXME: This DOES work. However, while ActiveRecord::Persistence defines a create_record method
      # the call in create_or_update is actually calling the method create_record in the Dirty concern
      # which removes the pkey attrs and also sets updated/created at timestamps
      # For some reason when we overide here we lose dirty!
      # So, for now we don't have updating timestamps
      def create_record(attribute_names = nil)
        record_timestamps!
        attribute_names ||= keys_for_partial_write
        attributes_values = arel_attributes_with_values_for_create(attribute_names)

        new_id = self.class.unscoped.insert attributes_values
        self.id = new_id if self.class.primary_key

        @new_record = false
        id
      end

      def record_timestamps!
        if self.record_timestamps
          current_time = current_time_from_proper_timezone

          all_timestamp_attributes.each do |column|
            if respond_to?(column) && respond_to?("#{column}=") && self.send(column).nil?
              write_attribute(column.to_s, current_time)
            end
          end
        end
      end
    end
  end
end
