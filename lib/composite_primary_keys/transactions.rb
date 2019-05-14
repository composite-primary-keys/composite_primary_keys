module ActiveRecord
  module Transactions
    # Restore the new record state and id of a record that was previously saved by a call to save_record_state.
    def restore_transaction_record_state(force_restore_state = false)
      if restore_state = @_start_transaction_state
        if force_restore_state || restore_state[:level] <= 1
          @new_record = restore_state[:new_record]
          @destroyed  = restore_state[:destroyed]
          @attributes = restore_state[:attributes].map do |attr|
            value = @attributes.fetch_value(attr.name)
            attr = attr.with_value_from_user(value) if attr.value != value
            attr
          end
          @mutations_from_database = nil
          @mutations_before_last_save = nil

          # CPK
          if self.composite?
            values = @primary_key.map {|attribute| @attributes.fetch_value(attribute)}
            restore_id = restore_state[:id]
            if values != restore_id
              @primary_key.each_with_index do |attribute, i|
                @attributes.write_from_user(attribute, restore_id[i])
              end
            end
          elsif @attributes.fetch_value(@primary_key) != restore_state[:id]
            @attributes.write_from_user(@primary_key, restore_state[:id])
          end
          freeze if restore_state[:frozen?]
        end
      end
    end
  end
end
