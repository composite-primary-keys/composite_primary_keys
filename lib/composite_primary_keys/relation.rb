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

      stmt.set Arel.sql(@klass.send(:sanitize_sql_for_assignment, updates))
      stmt.table(table)

      if has_join_values?
        # CPK
        #@klass.connection.join_to_update(stmt, arel, arel_attribute(primary_key))
        if primary_key.kind_of?(Array)
          attributes = primary_key.map do |key|
            arel_attribute(key)
          end
          @klass.connection.join_to_update(stmt, arel, attributes.to_composite_keys)
        else
          @klass.connection.join_to_update(stmt, arel, arel_attribute(primary_key))
        end
      else
        stmt.key = arel_attribute(primary_key)
        stmt.take(arel.limit)
        stmt.order(*arel.orders)
        stmt.wheres = arel.constraints
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
      stmt.from(table)

      # CPK
      if has_join_values? && @klass.composite?
        arel_attributes = primary_key.map do |key|
          arel_attribute(key)
        end.to_composite_keys
        @klass.connection.join_to_delete(stmt, arel, arel_attributes)
      elsif has_join_values? || has_limit_or_offset?
        @klass.connection.join_to_delete(stmt, arel, arel_attribute(primary_key))
      else
        stmt.wheres = arel.constraints
      end

      affected = @klass.connection.delete(stmt, "#{@klass} Destroy")

      reset
      affected
    end
  end
end
