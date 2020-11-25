module CompositePrimaryKeys
  module ActiveRecord
    module Calculations
      def aggregate_column(column_name)
        # CPK
        if column_name.kind_of?(Array)
          column_name.map do |column|
            @klass.arel_attribute(column_name)
          end
        elsif @klass.has_attribute?(column_name) || @klass.attribute_alias?(column_name)
          @klass.arel_attribute(column_name)
        else
          Arel.sql(column_name == :all ? "*" : column_name.to_s)
        end
      end

      def execute_simple_calculation(operation, column_name, distinct) #:nodoc:
        column_alias = column_name

        # CPK
        # if operation == "count" && (column_name == :all && distinct || has_limit_or_offset?)
        #   # Shortcut when limit is zero.
        #   return 0 if limit_value == 0
        #
        #   query_builder = build_count_subquery(spawn, column_name, distinct)
        if operation == "count"
          relation = unscope(:order)
          query_builder = build_count_subquery(spawn, column_name, distinct)
        else
          # PostgreSQL doesn't like ORDER BY when there are no GROUP BY
          relation = unscope(:order).distinct!(false)

          column = aggregate_column(column_name)

          select_value = operation_over_aggregate_column(column, operation, distinct)
          if operation == "sum" && distinct
            select_value.distinct = true
          end

          column_alias = select_value.alias
          column_alias ||= @klass.connection.column_name_for_operation(operation, select_value)
          relation.select_values = [select_value]

          query_builder = relation.arel
        end

        result = skip_query_cache_if_necessary { @klass.connection.select_all(query_builder, nil) }
        row    = result.first
        value  = row && row.values.first
        type   = result.column_types.fetch(column_alias) do
          type_for(column_name)
        end

        type_cast_calculated_value(result.cast_values.first, operation) do |value|
          type = column.try(:type_caster) ||
            lookup_cast_type_from_join_dependencies(column_name.to_s) || Type.default_value
          type.deserialize(value)
        end
      end

      def build_count_subquery(relation, column_name, distinct)
        if column_name == :all
          relation.select_values = [ Arel.sql(::ActiveRecord::FinderMethods::ONE_AS_ONE) ] unless distinct
          if relation.select_values.first.is_a?(Array)
            relation.select_values = relation.select_values.first.map do |column|
              Arel::Attribute.new(@klass.unscoped.table, column)
            end
          end
        elsif column_name.is_a?(Array)
          relation.select_values = column_name.map do |column|
            Arel::Attribute.new(@klass.unscoped.table, column)
          end
        else
          column_alias = Arel.sql("count_column")
          relation.select_values = [ aggregate_column(column_name).as(column_alias) ]
        end

        subquery = relation.arel.as(Arel.sql("subquery_for_count"))
        select_value = operation_over_aggregate_column(column_alias || Arel.star, "count", false)

        Arel::SelectManager.new(subquery).project(select_value)
      end
    end
  end
end
