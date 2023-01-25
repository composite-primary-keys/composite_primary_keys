module CompositePrimaryKeys
  module Predicates
    # Similar to module_function, but does not make instance methods private.
    # https://idiosyncratic-ruby.com/8-self-improvement.html
    extend self

    def cpk_and_predicate(predicates)
      if predicates.length == 1
        predicates.first
      else
        Arel::Nodes::And.new(predicates)
      end
    end

    def cpk_or_predicate(predicates, group = true)
      if predicates.length <= 1
        predicates.first
      else
        split_point = predicates.length / 2
        predicates_first_half = predicates[0...split_point]
        predicates_second_half = predicates[split_point..-1]

        or_predicate = ::Arel::Nodes::Or.new(cpk_or_predicate(predicates_first_half, false),
                                             cpk_or_predicate(predicates_second_half, false))

        if group
          ::Arel::Nodes::Grouping.new(or_predicate)
        else
          or_predicate
        end
      end
    end

    def cpk_id_predicate(table, keys, values)
      # We zip on values then keys in case values are not provided for each key field
      eq_predicates = values.zip(keys).map do |value, key|
        table[key].eq(value)
      end
      cpk_and_predicate(eq_predicates)
    end

    def cpk_join_predicate(table1, key1, table2, key2)
      key1_fields = Array(key1).map {|key| table1[key]}
      key2_fields = Array(key2).map {|key| table2[key]}

      eq_predicates = key1_fields.zip(key2_fields).map do |key_field1, key_field2|
        key_field2 = Arel::Nodes::Quoted.new(key_field2) unless Arel::Attributes::Attribute === key_field2
        key_field1.eq(key_field2)
      end
      cpk_and_predicate(eq_predicates)
    end

    def cpk_in_predicate(table, primary_keys, ids)
      if primary_keys.length == 2
        low_cardinality_key_part, high_cardinality_key_part = if ids.map(&:second).uniq.size > ids.map(&:first).uniq.size
                                                                %i[first second]
                                                              else
                                                                %i[second first]
                                                              end

        groups = ids.group_by(&low_cardinality_key_part).transform_values do |values|
          values.map(&high_cardinality_key_part)
        end

        and_predicates = groups.map do |low_cardinality_value, high_cardinality_values|
          in_clause = table[primary_keys.send(high_cardinality_key_part)].in(high_cardinality_values.compact)
          inclusion_clauses = if high_cardinality_values.include?(nil)
                                Arel::Nodes::Grouping.new(
                                  Arel::Nodes::Or.new(
                                    in_clause,
                                    table[primary_keys.send(high_cardinality_key_part)].eq(nil)
                                  )
                                )
                              else
                                in_clause
                              end

          Arel::Nodes::And.new(
            [
              table[primary_keys.send(low_cardinality_key_part)].eq(low_cardinality_value),
              inclusion_clauses
            ]
          )
        end
      else
        and_predicates = ids.map do |id|
          cpk_id_predicate(table, primary_keys, id)
        end
      end

      cpk_or_predicate(and_predicates)
    end
  end
end

ActiveRecord::Associations::AssociationScope.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::JoinDependency::JoinAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::Preloader::Association.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::Preloader::Association::LoaderQuery.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::HasManyAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::HasManyThroughAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Base.send(:extend, CompositePrimaryKeys::Predicates)
ActiveRecord::Reflection::AbstractReflection.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Relation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::PredicateBuilder.send(:extend, CompositePrimaryKeys::Predicates)
