module CompositePrimaryKeys
  module Joins
    def composite_join_clause(table1, keys1, table2, keys2)
      predicates = composite_join_predicates(table1, keys1, table2, keys2)

      join_clause = predicates.map do |predicate|
        predicate.to_sql
      end.join(" AND ")

      "(#{join_clause})"
    end

    def composite_join_predicates(table1, keys1, table2, keys2)
      attributes1 = [keys1].flatten.map do |key|
        table1[key]
      end

      attributes2 = [keys2].flatten.map do |key|
        table2[key]
      end

      [attributes1, attributes2].transpose.map do |attribute1, attribute2|
        attribute1.eq(attribute2)
      end
    end
  end
end
