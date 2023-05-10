module ActiveRecord
  module Associations
    class HasManyThroughAssociation
      def through_records_for(record)
        # CPK
        # attributes = construct_join_attributes(record)
        # candidates = Array.wrap(through_association.target)
        # candidates.find_all do |c|
        #   attributes.all? do |key, value|
        #     c.public_send(key) == value
        #   end
        # end
        if record.composite?
          candidates = Array.wrap(through_association.target)
          candidates.find_all { |c| c.attributes.slice(*source_reflection.association_primary_key) == record.ids_hash }
        else
          attributes = construct_join_attributes(record)
          candidates = Array.wrap(through_association.target)
          candidates.find_all do |c|
            attributes.all? do |key, value|
              c.public_send(key) == value
            end
          end
        end
      end

      alias :original_construct_join_attributes :construct_join_attributes

      def construct_join_attributes(*records)
        # CPK
        if !self.source_reflection.polymorphic? && source_reflection.klass.composite?
          ensure_mutable

          ids = records.map do |record|
            source_reflection.association_primary_key(reflection.klass).map do |key|
              record.send(key)
            end
          end

          cpk_in_predicate(through_association.scope.klass.arel_table, source_reflection.foreign_key, ids)
        else
          original_construct_join_attributes(*records)
        end
      end
    end
  end
end
