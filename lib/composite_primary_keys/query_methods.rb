module ActiveRecord
  module QueryMethods
    def reverse_order
      order_clause = arel.order_clauses.join(', ')
      relation = except(:order)

      # CPK
      # order = order_clause.blank? ?
      #  "#{@klass.table_name}.#{@klass.primary_key} DESC" :
      #  reverse_sql_order(order_clause)

      order = unless order_clause.blank?
        reverse_sql_order(order_clause)
      else
        primary_keys = composite? ? @klass.primary_keys : [@klass.primary_key]
        primary_keys.map do |key|
          "#{@klass.table_name}.#{key} DESC"
        end.join(", ")
      end

      relation.order Arel::SqlLiteral.new order
    end
  end
end
