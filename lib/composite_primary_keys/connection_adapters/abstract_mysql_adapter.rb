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
        if key.is_a?(Array)
          key_names = key.map(&:name).map {|key_name| Arel.sql(key_name)}
          Arel::SelectManager.new(subselect.as("__active_record_temp")).project(key_names)
        else
          key_name = quote_column_name(key.name)
          Arel::SelectManager.new(subselect.as("__active_record_temp")).project(Arel.sql(key_name))
        end

        # CPK
        #subselect.project Arel.sql(key.name)
#        subselect.project Arel.sql(Array(key).map(&:name).join(', '))

 #       subselect.from subsubselect.as('__active_record_temp')
      end
    end
  end
end
