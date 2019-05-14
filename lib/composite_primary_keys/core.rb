module ActiveRecord
  module Core
    def initialize_dup(other) # :nodoc:
      @attributes = @attributes.deep_dup
      # CPK
      #@attributes.reset(@primary_key)
      Array(self.class.primary_key).each {|key| @attributes.reset(key)}

      _run_initialize_callbacks

      @new_record               = true
      @destroyed                = false
      @_start_transaction_state = nil
      @transaction_state        = nil

      super
    end

    module ClassMethods
      def find(*ids) # :nodoc:
        # We don't have cache keys for this stuff yet
        return super unless ids.length == 1
        return super if block_given? ||
            primary_key.nil? ||
            scope_attributes? ||
            columns_hash.key?(inheritance_column) && !base_class?

        # CPK
        return super if self.composite?

        id = ids.first

        return super if StatementCache.unsupported_value?(id)

        key = primary_key

        statement = cached_find_by_statement(key) { |params|
          where(key => params.bind).limit(1)
        }

        record = statement.execute([id], connection)&.first
        unless record
          raise RecordNotFound.new("Couldn't find #{name} with '#{key}'=#{id}", name, key, id)
        end
        record
      end
    end
  end
end