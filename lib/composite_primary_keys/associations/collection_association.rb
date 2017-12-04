module CompositePrimaryKeys
  module CollectionAssociation
    def get_records
      cpk_applies = target.try(:composite?) || owner.try(:composite?)
      return scope.to_a if cpk_applies
      super
    end

    def ids_reader
      if loaded?
        load_target.map do |record|
          if reflection.association_primary_key.is_a?(Array)
            reflection.association_primary_key.map { |key| record.send(key) }
          else
            record.send(reflection.association_primary_key)
          end
        end
      else
        @association_ids ||= (
        column = "#{reflection.quoted_table_name}.#{reflection.association_primary_key}"
        scope.pluck(column)
        )
      end
    end

    def ids_writer(ids)
      pk_type = reflection.association_primary_key_type
      ids = Array(ids).reject(&:blank?)
      ids.map! { |i| pk_type.cast(i) }

      # CPK
      if reflection.association_primary_key.is_a?(Array)
        predicate = CompositePrimaryKeys::Predicates.cpk_in_predicate(klass.arel_table, reflection.association_primary_key, ids)
        records = klass.where(predicate).index_by do |r|
          reflection.association_primary_key.map{ |k| r.send(k) }
        end.values_at(*ids)
      else
        primary_key = reflection.association_primary_key
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