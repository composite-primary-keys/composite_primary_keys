module CompositePrimaryKeys
  module CollectionAssociation
    def get_records
      cpk_applies = (target && target.respond_to?(:composite?) && target.composite?) || (owner && owner.respond_to?(:composite?) && owner.composite?)
      return scope.to_a if cpk_applies
      super
    end

    def ids_writer(ids)
      pk_type = reflection.primary_key_type
      ids = Array(ids).reject(&:blank?)
      ids.map! { |i| pk_type.cast(i) }
      # CPK
      # records = klass.where(reflection.association_primary_key => ids).index_by do |r|
      in_predicates = Class.new.extend(CompositePrimaryKeys::Predicates).cpk_in_predicate(klass.arel_table, reflection.association_primary_key, ids)
      records = klass.where(in_predicates).index_by do |r|
        reflection.association_primary_key.map{ |k| r.send(k) }
      end.values_at(*ids)
      replace(records)
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.prepend CompositePrimaryKeys::CollectionAssociation