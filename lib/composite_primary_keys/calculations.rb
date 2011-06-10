module ActiveRecord
  module Calculations
    alias :execute_simple_calculation_ar :execute_simple_calculation
    def execute_simple_calculation(operation, column_name, distinct)
      # CPK
      if column_name.kind_of?(Array)
        execute_simple_calculation_cpk(operation, column_name, distinct)
      else
        execute_simple_calculation_ar(operation, column_name, distinct)
      end
    end

    def execute_simple_calculation_cpk(operation, column_name, distinct)
      projection = self.primary_keys.map do |key|
        attribute = arel_table[key]
        self.arel.visitor.accept(attribute)
      end.join(', ')

     # relation = self.clone
     # relation.select_values = ["DISTINCT #{projection}"]

      manager = Arel::SelectManager.new(arel_engine)
      manager.project("DISTINCT #{projection}")
      manager.from(arel_table)
      
      query = Arel::Table.new('dummy').project('count(*)')
      query = query.from("(#{manager.to_sql}) AS subquery")
      type_cast_calculated_value(@klass.connection.select_value(query.to_sql), column_for(column_name), operation)
    end
  end
end
