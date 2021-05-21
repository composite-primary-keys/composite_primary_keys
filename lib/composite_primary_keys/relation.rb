module ActiveRecord
  class Relation
    alias :initialize_without_cpk :initialize
    def initialize(klass, table: klass.arel_table, predicate_builder: klass.predicate_builder, values: {})
      initialize_without_cpk(klass, table: table, predicate_builder: predicate_builder, values: values)
      add_cpk_support if klass && klass.composite?
    end

    alias :initialize_copy_without_cpk :initialize_copy
    def initialize_copy(other)
      initialize_copy_without_cpk(other)
      add_cpk_support if klass.composite?
    end

    def add_cpk_support
      extend CompositePrimaryKeys::CompositeRelation
    end

    def update_all(updates)
      raise ArgumentError, "Empty list of attributes to change" if updates.blank?

      if eager_loading?
        relation = apply_join_dependency
        return relation.update_all(updates)
      end

      stmt = Arel::UpdateManager.new
      stmt.table(arel.join_sources.empty? ? table : arel.source)
      stmt.key = table[primary_key]

      # CPK
      if @klass.composite? && @klass.connection.visitor.compile(stmt.ast) =~ /['"]#{primary_key.to_s}['"]/
        stmt = Arel::UpdateManager.new
        stmt.table(arel_table)
        cpk_subquery(stmt)
      else
        stmt.wheres = arel.constraints
      end
      stmt.take(arel.limit)
      stmt.offset(arel.offset)
      stmt.order(*arel.orders)

      if updates.is_a?(Hash)
        if klass.locking_enabled? &&
            !updates.key?(klass.locking_column) &&
            !updates.key?(klass.locking_column.to_sym)
          attr = table[klass.locking_column]
          updates[attr.name] = _increment_attribute(attr)
        end
        stmt.set _substitute_values(updates)
      else
        stmt.set Arel.sql(klass.sanitize_sql_for_assignment(updates, table.name))
      end

      @klass.connection.update stmt, "#{@klass} Update All"
    end

    def delete_all
      invalid_methods = INVALID_METHODS_FOR_DELETE_ALL.select do |method|
        value = @values[method]
        method == :distinct ? value : value&.any?
      end
      if invalid_methods.any?
        raise ActiveRecordError.new("delete_all doesn't support #{invalid_methods.join(', ')}")
      end

      if eager_loading?
        relation = apply_join_dependency
        return relation.delete_all
      end

      stmt = Arel::DeleteManager.new
      stmt.from(arel.join_sources.empty? ? table : arel.source)
      stmt.key = table[primary_key]

      # CPK
      if @klass.composite? && @klass.connection.visitor.compile(stmt.ast) =~ /['"]#{primary_key.to_s}['"]/
        stmt = Arel::DeleteManager.new
        stmt.from(arel_table)
        cpk_subquery(stmt)
      else
        stmt.wheres = arel.constraints
      end

      stmt.take(arel.limit)
      stmt.offset(arel.offset)
      stmt.order(*arel.orders)

      affected = @klass.connection.delete(stmt, "#{@klass} Destroy")

      reset
      affected
    end

    # CPK
    def cpk_subquery(stmt)
      # For update and delete statements we need a way to specify which records should
      # get updated. By default, Rails creates a nested IN subquery that uses the primary
      # key. Postgresql, Sqlite, MariaDb and Oracle support IN subqueries with multiple
      # columns but MySQL and SqlServer do not. Instead SQL server supports EXISTS queries
      # and MySQL supports obfuscated IN queries. Thus we need to check the type of
      # database adapter to decide how to proceed.
      if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter) && connection.is_a?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        cpk_mysql_subquery(stmt)
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLServerAdapter) && connection.is_a?(ActiveRecord::ConnectionAdapters::SQLServerAdapter)
        cpk_exists_subquery(stmt)
      else
        cpk_in_subquery(stmt)
      end
    end

    # Used by postgresql, sqlite, mariadb and oracle. Example query:
    #
    # UPDATE reference_codes
    # SET ...
    # WHERE (reference_codes.reference_type_id, reference_codes.reference_code) IN
    #      (SELECT reference_codes.reference_type_id, reference_codes.reference_code
    #       FROM reference_codes)
    def cpk_in_subquery(stmt)
      # Setup the subquery
      subquery = arel.clone
      subquery.projections = primary_keys.map do |key|
        arel_table[key]
      end

      where_fields = primary_keys.map do |key|
        arel_table[key]
      end
      where = Arel::Nodes::Grouping.new(where_fields).in(subquery)
      stmt.wheres = [where]
    end

    # CPK. This is an alternative to IN subqueries. It is used by sqlserver.
    # Example query:
    #
    # UPDATE reference_codes
    # SET ...
    # WHERE EXISTS
    #  (SELECT 1
    #  FROM reference_codes cpk_child
    #  WHERE reference_codes.reference_type_id = cpk_child.reference_type_id AND
    #        reference_codes.reference_code = cpk_child.reference_code)
    def cpk_exists_subquery(stmt)
      arel_attributes = primary_keys.map do |key|
        table[key]
      end.to_composite_keys

      # Clone the query
      subselect = arel.clone

      # Alias the table - we assume just one table
      aliased_table = subselect.froms.first
      aliased_table.table_alias = "cpk_child"

      # Project - really we could just set this to "1"
      subselect.projections = arel_attributes

      # Setup correlation to the outer query via where clauses
      primary_keys.map do |key|
        outer_attribute = arel_table[key]
        inner_attribute = aliased_table[key]
        where = outer_attribute.eq(inner_attribute)
        subselect.where(where)
      end
      stmt.wheres = [Arel::Nodes::Exists.new(subselect)]
    end

    # CPK. This is the old way CPK created subqueries and is used by MySql.
    # MySQL does not support referencing the same table that is being UPDATEd or
    # DELETEd in a subquery so we obfuscate it. The ugly query looks like this:
    #
    # UPDATE `reference_codes`
    # SET ...
    # WHERE (reference_codes.reference_type_id, reference_codes.reference_code) IN
    #  (SELECT reference_type_id,reference_code
    #   FROM (SELECT DISTINCT `reference_codes`.`reference_type_id`, `reference_codes`.`reference_code`
    #         FROM `reference_codes`) __active_record_temp)
    def cpk_mysql_subquery(stmt)
      arel_attributes = primary_keys.map do |key|
        table[key]
      end.to_composite_keys

      subselect = arel.clone
      subselect.projections = arel_attributes

      # Materialize subquery by adding distinct
      # to work with MySQL 5.7.6 which sets optimizer_switch='derived_merge=on'
      subselect.distinct unless arel.limit || arel.offset || arel.orders.any?

      key_name = arel_attributes.map(&:name).join(',')

      manager = Arel::SelectManager.new(subselect.as("__active_record_temp")).project(Arel.sql(key_name))

      stmt.wheres = [Arel::Nodes::In.new(arel_attributes, manager.ast)]
    end
  end
end
