module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
      # MySQL is too stupid to create a temporary table for use subquery, so we have
      # to give it some prompting in the form of a subsubquery. Ugh!
      def subquery_for(key, select)
        subsubselect = select.clone
        subsubselect.projections = [key]

        # Materialize subquery by adding distinct
        # to work with MySQL 5.7.6 which sets optimizer_switch='derived_merge=on'
        subsubselect.distinct unless select.limit || select.offset || select.orders.any?

        subselect = Arel::SelectManager.new(select.engine)

        # subselect.project Arel.sql(key.name)
        arel_table = select.engine.arel_table
        subselect.project *[key].map { |x| arel_table[x.name] }
        subselect.from subsubselect.as('__active_record_temp')
      end
    end
  end
end
