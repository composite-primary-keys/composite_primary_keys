module CompositePrimaryKeys
  module ActiveRecord
    module QueryMethods
      def reverse_sql_order(order_query)
        if order_query.empty?
          # CPK
          # return [table[primary_key].desc] if primary_key

          if primary_key
            # break apart CPKs
            return primary_key.map do |key|
              table[key].desc
            end
          else
            raise IrreversibleOrderError,
                  "Relation has no current order and table has no primary key to be used as default order"
          end
        end

        order_query.flat_map do |o|
          order_query.flat_map do |o|
            case o
            when Arel::Attribute
              o.desc
            when Arel::Nodes::Ordering
              o.reverse
            when String
              if does_not_support_reverse?(o)
                raise IrreversibleOrderError, "Order #{o.inspect} can not be reversed automatically"
              end
              o.split(",").map! do |s|
                s.strip!
                s.gsub!(/\sasc\Z/i, " DESC") || s.gsub!(/\sdesc\Z/i, " ASC") || (s << " DESC")
              end
            else
              o
            end
          end
        end
      end
    end
  end
end