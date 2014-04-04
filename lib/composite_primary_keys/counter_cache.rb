module ActiveRecord
  module CounterCache
    def update_counters(ids, counters)
      ids = [ids] unless ids.is_a?(Array) && ids.all? do |id|
        id.is_a?(Array) || /^\d+$/ =~ id.to_s
      end

      updates = counters.map do |counter_name, value|
        operator = value < 0 ? '-' : '+'
        quoted_column = connection.quote_column_name(counter_name)
        "#{quoted_column} = COALESCE(#{quoted_column}, 0) #{operator} #{value.abs}"
      end

      primary_key_predicate = ids.reduce(nil) do |res, id|
        if IdentityMap.enabled?
          IdentityMap.remove_by_id(symbolized_base_class, id)
        end

        # CPK
        # update_all(updates.join(', '), primary_key => id )
        primary_key_predicate = relation.cpk_id_predicate(self.arel_table,
                                Array(self.primary_key), Array(id))
        res.or(primary_key_predicate) rescue primary_key_predicate
      end
      update_all(updates.join(', '), primary_key_predicate)
    end

    def decrement_counter(counter_name, id)
      update_counters(id, counter_name => -1)
    end
  end
end
