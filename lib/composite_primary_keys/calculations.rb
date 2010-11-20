# TODO - This code doesn't work with ActiveRecord 3.0.3...

#module ActiveRecord
#  module Calculations
#    def execute_simple_calculation(operation, column_name, distinct)
#      # CPK changes
#      if column_name.kind_of?(Array)
#        columns = column_name.map do |primary_key_column|
#          table[primary_key_column].to_sql
#        end
#        projection = "DISTINCT #{columns.join(',')}"
#        subquery = "(#{table.project(projection).to_sql}) AS subquery"
#        relation = Arel::Table.new(subquery).project(Arel::SqlLiteral.new('*').count)
#        type_cast_calculated_value(@klass.connection.select_value(relation.to_sql),
#                                   column_for(column_name.first), operation)
#      else
#        column = if @klass.column_names.include?(column_name.to_s)
#          Arel::Attribute.new(@klass.unscoped, column_name)
#        else
#          Arel::SqlLiteral.new(column_name == :all ? "*" : column_name.to_s)
#        end
#
#        # Postgresql doesn't like ORDER BY when there are no GROUP BY
#        relation = except(:order).select(operation == 'count' ? column.count(distinct) : column.send(operation))
#        type_cast_calculated_value(@klass.connection.select_value(relation.to_sql), column_for(column_name), operation)
#      end
#    end
#  end
#end
