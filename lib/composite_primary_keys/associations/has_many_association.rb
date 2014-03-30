module ActiveRecord
  module Associations
    class HasManyAssociation
      def delete_records(records, method)
        if method == :destroy
          records.each(&:destroy!)
          update_counter(-records.length) unless inverse_updates_counter_cache?
        else
          if records == :all || !reflection.klass.primary_key
            scope = self.scope
          else
            # CPK
            # scope = self.scope.where(reflection.klass.primary_key => records)
            # scope = self.scope.where(reflection.klass.primary_key => records)
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

            scope = self.scope.where(condition)
          end

          if method == :delete_all
            update_counter(-scope.delete_all)
          else
            update_counter(-scope.update_all(reflection.foreign_key => nil))
          end
        end
      end

      def foreign_key_present?
        if reflection.klass.primary_key
          # CPK
          #owner.attribute_present?(reflection.association_primary_key)
          owner.attribute_present?(reflection.association_primary_key)
          Array(reflection.klass.primary_key).all? {|key| owner.attribute_present?(key)}
        else
          false
        end
      end
    end
  end
end
