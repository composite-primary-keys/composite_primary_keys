module ActiveRecord
  module CounterCache
    module ClassMethods      
      def update_counters(id, counters)
        updates = counters.map do |counter_name, value|
          operator = value < 0 ? '-' : '+'
          quoted_column = connection.quote_column_name(counter_name)
          "#{quoted_column} = COALESCE(#{quoted_column}, 0) #{operator} #{value.abs}"
        end

        # CPK
        # update_all(updates.join(', '), primary_key => id )
        primary_key_predicate = relation.cpk_id_predicate(self.arel_table, Array(self.primary_key), Array(id))
        update_all(updates.join(', '), primary_key_predicate)
      end

      def decrement_counter(counter_name, id)
        update_counters(id, counter_name => -1)
      end
    end
  end
end