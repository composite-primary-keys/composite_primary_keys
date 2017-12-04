module ActiveRecord
  module Locking
    module Optimistic
      def _update_record(attribute_names = self.attribute_names)
        return super unless locking_enabled?
        return 0 if attribute_names.empty?

        begin
          lock_col = self.class.locking_column

          previous_lock_value = read_attribute_before_type_cast(lock_col)

          increment_lock

          attribute_names.push(lock_col)

          relation = self.class.unscoped

          # CPK
          if self.composite?
            affected_rows = relation.where(
                relation.cpk_id_predicate(relation.table, self.class.primary_key, id)
            ).where(
                lock_col => previous_lock_value
            ).update_all(
                attributes_for_update(attribute_names).map do |name|
                  [name, _read_attribute(name)]
                end.to_h
            )
          else
            affected_rows = relation.where(
                self.class.primary_key => id,
                lock_col => previous_lock_value
            ).update_all(
                attributes_for_update(attribute_names).map do |name|
                  [name, _read_attribute(name)]
                end.to_h
            )
          end

          unless affected_rows == 1
            raise ActiveRecord::StaleObjectError.new(self, "update")
          end

          affected_rows

            # If something went wrong, revert the locking_column value.
        rescue Exception
          send("#{lock_col}=", previous_lock_value.to_i)

          raise
        end
      end
    end
  end
end
