module ActiveRecord
  module Associations
    class HasManyAssociation
      def delete_records(records, method)
        if method == :destroy
          records.each(&:destroy!)
          update_counter(-records.length) unless reflection.inverse_updates_counter_cache?
        # CPK
        elsif self.reflection.klass.composite?
          predicate = cpk_in_predicate(self.scope.table, self.reflection.klass.primary_keys, records.map(&:id))
          scope = self.scope.where(predicate)
          update_counter(-delete_count(method, scope))
        else
          scope = self.scope.where(reflection.klass.primary_key => records)
          update_counter(-delete_count(method, scope))
        end
      end

      def delete_count(method, scope)
        if method == :delete_all
          scope.delete_all
        else
          # CPK
          # scope.update_all(nullified_owner_attributes)
          conds = Array(reflection.foreign_key).inject(Hash.new) do |mem, key|
            mem[key] = nil
            mem
          end
          conds[reflection.type] = nil if reflection.type.present?
          scope.update_all(conds)
        end
      end
    end
  end
end
