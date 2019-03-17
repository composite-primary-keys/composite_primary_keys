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
      if @klass.composite?
        arel_attributes = primary_key.map do |key|
          arel_attribute(key)
        end.to_composite_keys
        subselect = arel.clone
        subselect.projections = [arel_attributes]
        stmt.table(table)
        stmt.key = arel_attributes.in(subselect)
      else
        stmt.table(arel.join_sources.empty? ? table : arel.source)
        stmt.key = arel_attribute(primary_key)
      end
      stmt.take(arel.limit)
      stmt.offset(arel.offset)
      stmt.order(*arel.orders)
      stmt.wheres = arel.constraints

      if updates.is_a?(Hash)
        stmt.set _substitute_values(updates)
      else
        stmt.set Arel.sql(klass.sanitize_sql_for_assignment(updates, table.name))
      end

      @klass.connection.update stmt, "#{@klass} Update All"
    end

    def delete_all
      invalid_methods = INVALID_METHODS_FOR_DELETE_ALL.select do |method|
        value = get_value(method)
        SINGLE_VALUE_METHODS.include?(method) ? value : value.any?
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
        arel_attributes = primary_key.map do |key|
          arel_attribute(key)
        end.to_composite_keys
        subselect = arel.clone
        subselect.projections = [arel_attributes]
        stmt.from(table)
        stmt.key = arel_attributes.in(subselect)
      else
        stmt.from(arel.join_sources.empty? ? table : arel.source)
        stmt.key = arel_attribute(primary_key)
      end
      stmt.take(arel.limit)
      stmt.offset(arel.offset)
      stmt.order(*arel.orders)
      stmt.wheres = arel.constraints

      affected = @klass.connection.delete(stmt, "#{@klass} Destroy")

      reset
      affected
    end
  end
end
