module CompositePrimaryKeys
  module ActiveRecord
    module Locking
      module Optimistic
        private
          def _update_record(attribute_names = @attributes.keys) #:nodoc:
            return super unless locking_enabled?
            return 0 if attribute_names.empty?

            lock_col = self.class.locking_column
            previous_lock_value = send(lock_col).to_i
            increment_lock

            attribute_names += [lock_col]
            attribute_names.uniq!

            begin
              relation = self.class.unscoped

              if self.composite?
                stmt = relation.where(
                  relation.cpk_id_predicate(relation.table, self.class.primary_key, id_was).and(
                    relation.table[lock_col].eq(self.class.quote_value(previous_lock_value, column_for_attribute(lock_col)))
                  )
                ).arel.compile_update(arel_attributes_with_values_for_update(attribute_names))
              else
                stmt = relation.where(
                  relation.table[self.class.primary_key].eq(id).and(
                    relation.table[lock_col].eq(self.class.quote_value(previous_lock_value, column_for_attribute(lock_col)))
                  )
                ).arel.compile_update(arel_attributes_with_values_for_update(attribute_names))
              end

              affected_rows = self.class.connection.update stmt

              unless affected_rows == 1
                raise ::ActiveRecord::StaleObjectError.new(self, "update")
              end

              affected_rows

            # If something went wrong, revert the version.
            rescue Exception
              send(lock_col + '=', previous_lock_value)
              raise
            end
          end
      end
    end
  end
end
