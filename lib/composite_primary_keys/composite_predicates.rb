module CompositePrimaryKeys
  module Predicates
    def cpk_and_predicate(predicates)
      if predicates.length == 1
        predicates.first
      else
        Arel::Nodes::And.new(predicates)
      end
    end

    def cpk_or_predicate(predicates)
      if predicates.length <= 1
        predicates
      else
        predicates_copy = predicates.dup
        or_predicate = ::Arel::Nodes::Or.new(*(predicates_copy.slice!(0,2)))
        or_predicate = predicates_copy.inject(or_predicate) do |mem, predicate|
          ::Arel::Nodes::Or.new(mem, predicate)
        end
        # or_predicate = predicates.map do |predicate|
        #   ::Arel::Nodes::Grouping.new(predicate)
        # end.inject do |memo, node|
        #   ::Arel::Nodes::Or.new(memo, node)
        # end

        ::Arel::Nodes::Grouping.new(or_predicate)
      end
    end

    def cpk_id_predicate(table, keys, values)
      eq_predicates = keys.zip(values).map do |key, value|
        table[key].eq(value)
      end
      cpk_and_predicate(eq_predicates)
    end

    def cpk_join_predicate(table1, key1, table2, key2)
      key1_fields = Array(key1).map {|key| table1[key]}
      key2_fields = Array(key2).map {|key| table2[key]}

      eq_predicates = key1_fields.zip(key2_fields).map do |key_field1, key_field2|
        key_field1.eq(key_field2)
      end
      cpk_and_predicate(eq_predicates)
    end

    def cpk_in_predicate(table, primary_keys, ids)
      and_predicates = ids.map do |id|
        cpk_id_predicate(table, primary_keys, id)
      end
      cpk_or_predicate(and_predicates)
    end
  end
end

ActiveRecord::Associations::AssociationScope.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::JoinDependency::JoinAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::Preloader::Association.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::HasManyThroughAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Relation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::PredicateBuilder.send(:extend, CompositePrimaryKeys::Predicates)