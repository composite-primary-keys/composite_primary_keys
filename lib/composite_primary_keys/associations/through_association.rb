module ActiveRecord
  module Associations
    module ThroughAssociation

      private

      original_construct_join_attributes = instance_method(:construct_join_attributes)

      define_method(:construct_join_attributes) do |*records|
        if source_reflection.klass.composite?
          # CPK
          ensure_mutable

          ids = records.map do |record|
            source_reflection.association_primary_key(reflection.klass).map do |key|
              record.send(key)
            end
          end

          cpk_in_predicate(through_association.scope.klass.arel_table, source_reflection.foreign_key, ids)
        else
          original_construct_join_attributes.bind(self).call(*records)
        end
      end
    end
  end
end
