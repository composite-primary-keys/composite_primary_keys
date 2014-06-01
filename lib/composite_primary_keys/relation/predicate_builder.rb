module ActiveRecord
  class PredicateBuilder
    def self.expand(klass, table, column, value)
      queries = []
      if klass && reflection = klass.reflect_on_association(column.to_sym)
        if reflection.polymorphic? && base_class = polymorphic_base_class_from_value(value)
          queries << build(table[reflection.foreign_type], base_class)
        end

        column = reflection.foreign_key
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