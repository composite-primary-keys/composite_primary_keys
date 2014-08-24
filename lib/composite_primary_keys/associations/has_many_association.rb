module ActiveRecord
  module Associations
    class HasManyAssociation
      def delete_records(records, method)
        if method == :destroy
          records.each(&:destroy!)
          update_counter(-records.length) unless inverse_updates_counter_cache?
        else
          scope = self.scope.where(reflection.klass.primary_key => records)
          update_counter(-delete_count(method, scope))
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
