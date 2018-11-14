module ActiveRecord
  module CounterCache
    module ClassMethods
      def update_counters(id, counters)
        touch = counters.delete(:touch)

        updates = counters.map do |counter_name, value|
          operator = value < 0 ? "-" : "+"
          quoted_column = connection.quote_column_name(counter_name)
          "#{quoted_column} = COALESCE(#{quoted_column}, 0) #{operator} #{value.abs}"
        end

        if touch
          names = touch if touch != true
          touch_updates = touch_attributes_with_time(*names)
          updates << sanitize_sql_for_assignment(touch_updates) unless touch_updates.empty?
        end

        if id.is_a?(Relation) && self == id.klass
          relation = id
        # CPK
        elsif primary_key.is_a?(Array)
          predicate = self.cpk_id_predicate(self.arel_table, self.primary_key, id)
          relation = unscoped.where!(predicate)
        else
          relation = unscoped.where!(primary_key => id)
        end

        relation.update_all updates.join(", ")
      end
    end
  end
end
