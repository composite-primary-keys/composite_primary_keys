module ActiveRecord
  module Associations
    class HasManyAssociation
      def delete_records(records, method)
        if method == :destroy
          records.each { |r| r.destroy }
          update_counter(-records.length) unless inverse_updates_counter_cache?
        else
          # CPK
          # keys  = records.map { |r| r[reflection.association_primary_key] }
          # scope = scoped.where(reflection.association_primary_key => keys)
          table = Arel::Table.new(reflection.table_name)
          and_conditions = records.map do |record|
            eq_conditions = Array(reflection.association_primary_key).map do |name|
              table[name].eq(record[name])
            end
            Arel::Nodes::And.new(eq_conditions)
          end

          condition = and_conditions.shift
          and_conditions.each do |and_condition|
            condition = condition.or(and_condition)
          end

          scope = scoped.where(condition)

          if method == :delete_all
            update_counter(-scope.delete_all)
          else
            # CPK
            # update_counter(-scope.update_all(reflection.foreign_key => nil))
            updates = Array(reflection.foreign_key).inject(Hash.new) do |hash, name|
              hash[name] = nil
              hash
            end
            update_counter(-scope.update_all(updates))
          end
        end
      end
    end
  end
end
