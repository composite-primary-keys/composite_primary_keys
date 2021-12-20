module CompositePrimaryKeys
  module ActiveRecord
    module Calculations
      def aggregate_column(column_name)
        # CPK
        if column_name.kind_of?(Array)
          # Note: Test don't seem to run this code?
          column_name.map do |column|
            @klass.arel_table[column]
          end
        elsif @klass.has_attribute?(column_name) || @klass.attribute_alias?(column_name)
          @klass.arel_table[column_name]
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
          select_value.distinct = true if operation == "sum" && distinct

          relation.select_values = [select_value]

          query_builder = relation.arel
        end

        result = skip_query_cache_if_necessary { @klass.connection.select_all(query_builder) }

        if operation != "count"
          type = column.try(:type_caster) ||
            lookup_cast_type_from_join_dependencies(column_name.to_s) || Type.default_value
          type = type.subtype if Enum::EnumType === type
        end

        type_cast_calculated_value(result.cast_values.first, operation, type) do |value|
          type = column.try(:type_caster) ||
            # CPK
            # lookup_cast_type_from_join_dependencies(column_name.to_s) || Type.default_value
            lookup_cast_type_from_join_dependencies(column_name.to_s) || ::ActiveRecord::Type.default_value
          type.deserialize(value)
        end
      end

      def build_count_subquery(relation, column_name, distinct)
        if column_name == :all
          column_alias = Arel.star
          # CPK
          # relation.select_values = [ Arel.sql(FinderMethods::ONE_AS_ONE) ] unless distinct
          relation.select_values = [ Arel.sql(::ActiveRecord::FinderMethods::ONE_AS_ONE) ] unless distinct
        elsif column_name.is_a?(Array)
          column_alias = Arel.star
          relation.select_values = column_name.map do |column|
            Arel::Attribute.new(@klass.unscoped.table, column)
          end
        else
          column_alias = Arel.sql("count_column")
          relation.select_values = [ aggregate_column(column_name).as(column_alias) ]
        end

        subquery_alias = Arel.sql("subquery_for_count")
        select_value = operation_over_aggregate_column(column_alias, "count", false)

        relation.build_subquery(subquery_alias, select_value)
      end

      def calculate(operation, column_name)
        if has_include?(column_name)
          relation = apply_join_dependency

          if operation.to_s.downcase == "count"
            unless distinct_value || distinct_select?(column_name || select_for_count)
              relation.distinct!
              # CPK
              # relation.select_values = [ klass.primary_key || table[Arel.star] ]
              if klass.primary_key.present? && klass.primary_key.is_a?(Array)
                relation.select_values = klass.primary_key.map do |k|
                  "#{connection.quote_table_name(klass.table_name)}.#{connection.quote_column_name(k)}"
                end
              else
                relation.select_values = [ klass.primary_key || table[Arel.star] ]
              end
            end
            # PostgreSQL: ORDER BY expressions must appear in SELECT list when using DISTINCT
            relation.order_values = [] if group_values.empty?
          end

          relation.calculate(operation, column_name)
        else
          perform_calculation(operation, column_name)
        end
      end
    end
  end
end
