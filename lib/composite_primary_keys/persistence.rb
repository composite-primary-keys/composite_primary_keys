module CompositePrimaryKeys
  module ActiveRecord
    module Persistence
      def relation_for_destroy
        return super unless composite?
        
        primary_keys = Array(self.class.primary_key)

        if primary_keys.empty?
          raise ActiveRecord::CompositeKeyError, "No primary key(s) defined for #{self.class.name}"
        end

        where_hash = primary_keys.inject(Hash.new) do |hash, key|
          hash[key.to_s] = self[key]
          hash
        end

        relation = self.class.unscoped.where(where_hash)
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

          primary_key = self.class.primary_key

          # CPK
          #self.class.unscoped.where(primary_key => self[primary_key]).update_all(changes) == 1
          primary_key_predicate = relation.cpk_id_predicate(arel_table, Array(primary_key), Array(id))
          self.class.unscoped.where(primary_key_predicate).update_all(changes) == 1
        else
          true
        end
      end

      # This override ensures that pkeys are set on the instance when records are created.
      # However, while ActiveRecord::Persistence defines a create_record method
      # the call in create_or_update is actually calling the method create_record in the Dirty concern
      # which removes the pkey attrs and also sets updated/created at timestamps
      # For some reason when we overide here we lose dirty!
      # So, for now, timestamps are recorded explicitly
      # def create_record(attribute_names = nil)
      #   record_timestamps!
      #   attribute_names ||= keys_for_partial_write
      #    attributes_values = arel_attributes_with_values_for_create(attribute_names)
      #
      #   new_id = self.class.unscoped.insert attributes_values
      #   self.id = new_id if self.class.primary_key
      #
      #   @new_record = false
      #   id
      # end
      #
      # def record_timestamps!
      #   if self.record_timestamps
      #     current_time = current_time_from_proper_timezone
      #
      #     all_timestamp_attributes.each do |column|
      #       if respond_to?(column) && respond_to?("#{column}=") && self.send(column).nil?
      #         write_attribute(column.to_s, current_time)
      #       end
      #     end
      #   end
      # end
    end
  end
end
