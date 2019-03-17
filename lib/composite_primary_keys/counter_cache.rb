module ActiveRecord
  module CounterCache
    module ClassMethods
      def update_counters(id, counters)
        # CPK
        if self.composite?
          predicate = cpk_id_predicate(self.arel_table, primary_key, id)
          unscoped.where!(predicate).update_counters(counters)
        else
          unscoped.where!(primary_key => id).update_counters(counters)
        end
      end
    end
  end
end
