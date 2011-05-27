module CompositePrimaryKeys
  module ActiveRecord
    module QueryMethods
      def reverse_order
        order_clause = arel.order_clauses

        # CPK
        # order = order_clause.empty? ?
        #  "#{table_name}.#{primary_key} DESC" :
        #  reverse_sql_order(order_clause).join(', ')

        order = unless order_clause.empty?
          reverse_sql_order(order_clause).join(', ')
        else
          klass.primary_key.map do |key|
            "#{table_name}.#{key} DESC"
          end.join(", ")
        end

        except(:order).order(Arel.sql(order))
      end
    end
  end
end