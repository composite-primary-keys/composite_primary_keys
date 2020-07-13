module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      def subquery_for(key, select)
        subselect = select.clone
        subselect.projections = [key]

        # Materialize subquery by adding distinct
        # to work with MySQL 5.7.6 which sets optimizer_switch='derived_merge=on'
        subselect.distinct unless select.limit || select.offset || select.orders.any?

        # CPK
        #key_name = quote_column_name(key.name)
        key_name = Array.wrap(key).map {|a_key| quote_column_name(a_key.name)}.join(',')

        Arel::SelectManager.new(subselect.as("__active_record_temp")).project(Arel.sql(key_name))
      end
    end
  end
end
