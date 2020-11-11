module ActiveRecord
  class Relation
    alias :initialize_without_cpk :initialize
    def initialize(klass, table: klass.arel_table, predicate_builder: klass.predicate_builder, values: {})
      initialize_without_cpk(klass, table: table, predicate_builder: predicate_builder, values: values)
      add_cpk_support if klass && klass.composite?
    end

    alias :initialize_copy_without_cpk :initialize_copy
    def initialize_copy(other)
      initialize_copy_without_cpk(other)
      add_cpk_support if klass.composite?
    end

    def add_cpk_support
      extend CompositePrimaryKeys::CompositeRelation
    end

    def update_all(updates)
      raise ArgumentError, "Empty list of attributes to change" if updates.blank?

      if eager_loading?
        relation = apply_join_dependency
        return relation.update_all(updates)
      end

      stmt = Arel::UpdateManager.new
      # CPK
      if @klass.composite?
        stmt.table(arel_table)
        cpk_in_subquery(stmt)
      else
        stmt.table(arel.join_sources.empty? ? table : arel.source)
        stmt.key = arel_attribute(primary_key)
        stmt.wheres = arel.constraints
      end
      stmt.take(arel.limit)
      stmt.offset(arel.offset)
      stmt.order(*arel.orders)

      if updates.is_a?(Hash)
        if klass.locking_enabled? &&
            !updates.key?(klass.locking_column) &&
            !updates.key?(klass.locking_column.to_sym)
          attr = arel_attribute(klass.locking_column)
          updates[attr.name] = _increment_attribute(attr)
        end
        stmt.set _substitute_values(updates)
      else
        stmt.set Arel.sql(klass.sanitize_sql_for_assignment(updates, table.name))
      end

      @klass.connection.update stmt, "#{@klass} Update All"
    end

    def delete_all
      invalid_methods = INVALID_METHODS_FOR_DELETE_ALL.select do |method|
        value = @values[method]
        method == :distinct ? value : value&.any?
      end
      if invalid_methods.any?
        raise ActiveRecordError.new("delete_all doesn't support #{invalid_methods.join(', ')}")
      end

      if eager_loading?
        relation = apply_join_dependency
        return relation.delete_all
      end

      stmt = Arel::DeleteManager.new

      if @klass.composite?
        stmt.from(arel_table)
        cpk_in_subquery(stmt)
      else
        stmt.from(arel.join_sources.empty? ? table : arel.source)
        stmt.key = arel_attribute(primary_key)
        stmt.wheres = arel.constraints
      end

      stmt.take(arel.limit)
      stmt.offset(arel.offset)
      stmt.order(*arel.orders)

      affected = @klass.connection.delete(stmt, "#{@klass} Destroy")

      reset
      affected
    end

    # CPK
    def cpk_in_subquery(stmt)
      # Setup the subquery
      subquery = arel.clone
      subquery.projections = primary_keys.map do |key|
        arel_table[key]
      end

      where_fields = primary_keys.map do |key|
        arel_table[key]
      end
      where = Arel::Nodes::Grouping.new(where_fields).in(subquery)
      stmt.wheres = [where]
    end

    def cpk_exists_subquery(stmt)
      # Alias the outer table so we can join to in from the subquery
      aliased_table = arel_table.alias("cpk_outer_relation")
      stmt.table(aliased_table)

      # Setup the subquery
      subquery = arel.clone
      subquery.projections = primary_keys.map do |key|
        arel_table[key]
      end

      # Setup correlation to the outer query via where clauses
      primary_keys.map do |key|
        outer_attribute = aliased_table[key]
        inner_attribute = arel_table[key]
        where = outer_attribute.eq(inner_attribute)
        subquery.where(where)
      end
      stmt.wheres = [Arel::Nodes::Exists.new(subquery)]
    end
  end
end
