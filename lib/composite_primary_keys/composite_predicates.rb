module CompositePrimaryKeys
  module Predicates
    def cpk_and_predicate(predicates)
      if predicates.length == 1
        predicates.first
      else
        Arel::Nodes::And.new(predicates)
      end
    end

    def figure_engine(table)
      case table
        when Arel::Nodes::TableAlias
          table.left.engine
        when Arel::Table
          table.engine
        when ::ActiveRecord::Base
          table
        else
          nil
      end
    end

    def cpk_or_predicate(predicates, table = nil)
      engine = figure_engine(table)
      predicates = predicates.map do |predicate|
        predicate_sql = engine ? predicate.to_sql(engine) : predicate.to_sql
        "(#{predicate_sql})"
      end
      predicates = "(#{predicates.join(" OR ")})"
      Arel::Nodes::SqlLiteral.new(predicates)
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
      and_predicates = ids.map do |id_set|
        eq_predicates = Array(primary_keys).zip(Array(id_set)).map do |primary_key, value|
          table[primary_key].eq(value)
        end
        cpk_and_predicate(eq_predicates)
      end

      cpk_or_predicate(and_predicates, table)
    end
  end
end

ActiveRecord::Associations::AssociationScope.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::HasAndBelongsToManyAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::JoinDependency::JoinAssociation.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Associations::Preloader::Association.send(:include, CompositePrimaryKeys::Predicates)
ActiveRecord::Relation.send(:include, CompositePrimaryKeys::Predicates)