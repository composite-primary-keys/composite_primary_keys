module CompositePrimaryKeys
  module CollectionAssociation
    def ids_writer(ids)
      primary_key = reflection.association_primary_key
      ids = Array(ids).reject(&:blank?)

      # CPK-
      if primary_key.is_a?(Array)
        ids = ids.map { |id| CompositePrimaryKeys::CompositeKeys.parse(id) }
        primary_key.each_with_index do |key, i|
          pk_type = klass.type_for_attribute(key)
          ids.each { |id| id[i] = pk_type.cast(id[i]) }
        end

        predicate = CompositePrimaryKeys::Predicates.cpk_in_predicate(klass.arel_table, reflection.association_primary_key, ids)
        records = klass.where(predicate).index_by do |r|
          reflection.association_primary_key.map{ |k| r.send(k) }
        end.values_at(*ids).compact
      else
        pk_type = klass.type_for_attribute(primary_key)
        ids.map! { |i| pk_type.cast(i) }

        records = klass.where(primary_key => ids).index_by do |r|
          r.public_send(primary_key)
        end.values_at(*ids).compact
      end

      if records.size != ids.size
        found_ids = records.map { |record| record.public_send(primary_key) }
        not_found_ids = ids - found_ids
        klass.all.raise_record_not_found_exception!(ids, records.size, ids.size, primary_key, not_found_ids)
      else
        replace(records)
      end
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.prepend CompositePrimaryKeys::CollectionAssociation