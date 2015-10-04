module ActiveRecord
  class PredicateBuilder
    def self.expand(klass, table, column, value)
      queries = []

      # Find the foreign key when using queries such as:
      # Post.where(author: author)
      #
      # For polymorphic relationships, find the foreign key and type:
      # PriceEstimate.where(estimate_of: treasure)
      if klass && reflection = klass._reflect_on_association(column)
        base_class = polymorphic_base_class_from_value(value)

        if reflection.polymorphic? && base_class
          queries << build(table[reflection.foreign_type], base_class)
        end

        column = reflection.foreign_key

        # CPK
        # if base_class
        if base_class && !(Base === value && value.composite?)
          primary_key = reflection.association_primary_key(base_class)
          value = convert_value_to_association_ids(value, primary_key)
        end
      end

      #CPK
      if Base === value && value.composite?
        queries << cpk_id_predicate(table, column, value.id)
      else
        queries << build(table[column], value)
      end
      queries
    end
  end
end
