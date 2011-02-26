#module ActiveRecord
#  module Calculations
#    alias :execute_simple_calculation_original :execute_simple_calculation
#
#    def execute_simple_calculation(operation, column_name, distinct)
#      if column_name.kind_of?(Array)
#        execute_simple_calculation_cpk(operation, column_name, distinct)
#      else
#        execute_simple_calculation_original(operation, column_name, distinct)
#      end
#    end
#
#    def execute_simple_calculation_cpk(operation, column_name, distinct)
#      # SELECT COUNT(field1, field2) doens't work so make a subquery
#      # like SELECT COUNT(*) FROM (SELECT DISTINCT field1, field2)
#
#      columns = column_name.map do |primary_key_column|
#        table[primary_key_column]
#      end
#
#      subquery = clone.project(columns)
#      subquery = "(#{subquery.to_sql}) AS calculation_subquery"
#      relation = Arel::Table.new(Arel::SqlLiteral.new(subquery))#.project(Arel::SqlLiteral.new('*').count)
#      puts relation.to_sql
#
#      #projection = "DISTINCT #{columns.join(',')}"
#      #subquery = "(#{table.project(projection).to_sql}) AS subquery"
#
#      #select_value = ::Arel::Nodes::Count.new(columns, distinct)
#  #    relation.select_values = columns
# #     puts @klass.connection.select_value(relation.to_sql)
##
#      #type_cast_calculated_value(@klass.connection.select_value(relation.to_sql), column_for(column_name), operation)
#      #relation.select_values = [count_node]
#      #projection = "DISTINCT #{columns.join(',')}"
#      #subquery = "(#{table.project(projection).to_sql}) AS subquery"
#      #relation = Arel::Table.new(subquery).project(Arel::SqlLiteral.new('*').count)
#      type_cast_calculated_value(@klass.connection.select_value(relation.to_sql),
#                                 column_for(column_name.first), operation)
#    end
#  end
#end
