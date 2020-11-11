module ActiveRecord
  module AttributeMethods
    module PrimaryKey
      module ClassMethods
        def suppress_composite_primary_key(pk)
          pk
          # return pk unless pk.is_a?(Array)
          #
          # warn <<~WARNING
          #         WARNING: Active Record does not support composite primary key.
          #
          #         #{table_name} has composite primary key. Composite primary key is ignored.
          # WARNING
        end
      end

      # Returns the primary key previous value.
      def id_was
        sync_with_transaction_state
        # CPK
        # attribute_was(self.class.primary_key)
        if self.composite?
          self.class.primary_keys.map do |key_attr|
            attribute_changed?(key_attr) ? changed_attributes[key_attr] : self.ids_hash[key_attr]
          end
        else
          attribute_was(self.class.primary_key)
        end
      end

      def id_in_database
        sync_with_transaction_state
        # CPK
        # attribute_in_database(self.class.primary_key)
        if self.composite?
          self.class.primary_keys.map do |key_attr|
            attribute_in_database(key_attr)
          end
        else
          attribute_in_database(self.class.primary_key)
        end
      end
    end
  end
end
