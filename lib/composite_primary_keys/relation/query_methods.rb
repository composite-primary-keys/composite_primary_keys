module ActiveRecord::QueryMethods
  alias :original_reverse_sql_order :reverse_sql_order
end

module CompositePrimaryKeys::ActiveRecord::QueryMethods

  def reverse_sql_order(order_query)
    
    # break apart CPKs 
    order_query = primary_key.map do |key|
      "#{quoted_table_name}.#{connection.quote_column_name(key)} ASC"
    end if order_query.empty?

    original_reverse_sql_order(order_query)
  end

end