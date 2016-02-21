module CompositePrimaryKeys
  module ActiveRecord
    module FinderMethods
      def apply_join_dependency(relation, join_dependency)
        relation = relation.except(:includes, :eager_load, :preload)
        relation = relation.joins join_dependency

        if using_limitable_reflections?(join_dependency.reflections)
          relation
        else
          if relation.limit_value
            limited_ids = limited_ids_for(relation)
            # CPK
            # limited_ids.empty? ? relation.none! : relation.where!(table[primary_key].in(limited_ids))
            limited_ids.empty? ? relation.none! : relation.where!(cpk_in_predicate(table, self.primary_keys, limited_ids))
          end
          relation.except(:limit, :offset)
        end
      end

      def limited_ids_for(relation)
        # CPK
        # values = @klass.connection.columns_for_distinct(
        #     "#{quoted_table_name}.#{quoted_primary_key}", relation.order_values)
        columns = @klass.primary_keys.map do |key|
          "#{quoted_table_name}.#{connection.quote_column_name(key)}"
        end
        values = @klass.connection.columns_for_distinct(columns, relation.order_values)

        relation = relation.except(:select).select(values).distinct!
        arel = relation.arel

        id_rows = @klass.connection.select_all(arel, 'SQL', relation.bound_attributes)

        # CPK
        #id_rows.map {|row| row[primary_key]}
        id_rows.map {|row| row.values}
      end

      def exists?(conditions = :none)
        if Base === conditions
          conditions = conditions.id
          ActiveSupport::Deprecation.warn(<<-MSG.squish)
          You are passing an instance of ActiveRecord::Base to `exists?`.
          Please pass the id of the object by calling `.id`
          MSG
        end

        return false if !conditions

        relation = apply_join_dependency(self, construct_join_dependency)
        return false if ActiveRecord::NullRelation === relation

        relation = relation.except(:select, :order).select(ONE_AS_ONE).limit(1)

        case conditions
          # CPK
          when CompositePrimaryKeys::CompositeKeys
            relation = relation.where(cpk_id_predicate(table, primary_key, conditions))
          # CPK
          when Array
            pk_length = @klass.primary_keys.length

            if conditions.length == pk_length # E.g. conditions = ['France', 'Paris']
              return self.exists?(conditions.to_composite_keys)
            else # Assume that conditions contains where relation
              relation = relation.where(conditions)
            end
          when Array, Hash
            relation = relation.where(conditions)
          else
            unless conditions == :none
              relation = relation.where(primary_key => conditions)
            end
        end

        connection.select_value(relation, "#{name} Exists", relation.bound_attributes) ? true : false
      end

      def find_with_ids(*ids)
        raise UnknownPrimaryKey.new(@klass) if primary_key.nil?

        # CPK
        # expects_array = ids.first.kind_of?(Array)
        ids = CompositePrimaryKeys.normalize(ids)
        expects_array = ids.flatten != ids.flatten(1)
        return ids.first if expects_array && ids.first.empty?

        # CPK
        # ids = ids.flatten.compact.uniq
        ids = expects_array ? ids.first : ids

        case ids.size
          when 0
            raise RecordNotFound, "Couldn't find #{@klass.name} without an ID"
          when 1
            result = find_one(ids.first)
            expects_array ? [ result ] : result
          else
            find_some(ids)
        end
      rescue RangeError
        raise RecordNotFound, "Couldn't find #{@klass.name} with an out of range ID"
      end

      def find_one(id)
        # CPK
        # if ActiveRecord::Base === id
        if ::ActiveRecord::Base === id
          id = id.id
          ActiveSupport::Deprecation.warn(<<-MSG.squish)
          You are passing an instance of ActiveRecord::Base to `find`.
          Please pass the id of the object by calling `.id`
          MSG
        end

        # CPK
        #relation = where(primary_key => id)
        relation = where(cpk_id_predicate(table, primary_keys, id))
        record = relation.take

        raise_record_not_found_exception!(id, 0, 1) unless record

        record
      end

      def find_some(ids)
        return find_some_ordered(ids) unless order_values.present?

        # CPK
        # result = where(primary_key => ids).to_a
        result = ids.map do |cpk_ids|
          cpk_ids = if cpk_ids.length == 1
                      cpk_ids.first.split(CompositePrimaryKeys::ID_SEP).to_composite_keys
                    else
                      cpk_ids.to_composite_keys
                    end

          unless cpk_ids.length == @klass.primary_keys.length
            raise "#{cpk_ids.inspect}: Incorrect number of primary keys for #{@klass.name}: #{@klass.primary_keys.inspect}"
          end

          new_relation = clone
          [@klass.primary_keys, cpk_ids].transpose.map do |key, id|
            new_relation = new_relation.where(key => id)
          end

          records = new_relation.to_a

          if records.empty?
            conditions = new_relation.arel.where_sql
            raise(::ActiveRecord::RecordNotFound,
                  "Couldn't find #{@klass.name} with ID=#{cpk_ids} #{conditions}")
          end
          records
        end.flatten

        expected_size =
            if limit_value && ids.size > limit_value
              limit_value
            else
              ids.size
            end

        # 11 ids with limit 3, offset 9 should give 2 results.
        if offset_value && (ids.size - offset_value < expected_size)
          expected_size = ids.size - offset_value
        end

        if result.size == expected_size
          result
        else
          raise_record_not_found_exception!(ids, result.size, expected_size)
        end
      end
    end
  end
end
