module CompositePrimaryKeys::ActiveRecord::QueryMethods

  def reverse_sql_order(order_query)
    # CPK
    # order_query = ["#{quoted_table_name}.#{quoted_primary_key} ASC"] if order_query.empty?

    # break apart CPKs 
    order_query = primary_key.map do |key|
      "#{quoted_table_name}.#{connection.quote_column_name(key)} ASC"
    end if order_query.empty?

    order_query.map do |o|
      case o
      when Arel::Nodes::Ordering
        o.reverse
      when String, Symbol
        o.to_s.split(',').collect do |s|
          s.strip!
          s.gsub!(/\sasc\Z/i, ' DESC') || s.gsub!(/\sdesc\Z/i, ' ASC') || s.concat(' DESC')
        end
      else
        o
      end
    end.flatten
  end


  def order(*args)    
    args.map! do |arg|
      if arg.is_a?(Arel::Nodes::Ordering) && arg.expr.name.is_a?(Array)
        arg = arg.expr.name.map do |key|
          cloned_node = arg.clone
          cloned_node.expr.name = key
          cloned_node
        end
      end
      arg
    end if composite?
    super(*args)
  end
end