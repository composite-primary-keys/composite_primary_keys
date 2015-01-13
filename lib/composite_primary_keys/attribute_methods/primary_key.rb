module ActiveRecord
  module AttributeMethods
    module PrimaryKey
      def id_was
        sync_with_transaction_state

        if self.composite?
          self.class.primary_keys.map do |key_attr|
            attribute_changed?(key_attr) ? changed_attributes[key_attr] : self.ids_hash[key_attr]
          end
        else
          attribute_was(self.class.primary_key)
        end
      end
    end
  end
end
