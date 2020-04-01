module CompositePrimaryKeys
  module ActiveRecord
    module FinderMethods
      def apply_join_dependency(eager_loading: true)
        join_dependency = construct_join_dependency
        relation = except(:includes, :eager_load, :preload).joins!(join_dependency)

        if eager_loading && !using_limitable_reflections?(join_dependency.reflections)
          if has_limit_or_offset?
            limited_ids = limited_ids_for(relation)

            # CPK
            # limited_ids.empty? ? relation.none! : relation.where!(primary_key => limited_ids)
            limited_ids.empty? ? relation.none! : relation.where!(cpk_in_predicate(table, self.primary_keys, limited_ids))

          end
          relation.limit_value = relation.offset_value = nil
        end

        if block_given?
          join_dependency.apply_column_aliases(relation)
          yield relation, join_dependency
        else
          relation
        end
      end

      def limited_ids_for(relation)
        # CPK
        # values = @klass.connection.columns_for_distinct(
        #     connection.column_name_from_arel_node(arel_attribute(primary_key)),
        #     relation.order_values
        # )

        columns = @klass.primary_keys.map do |key|
          connection.column_name_from_arel_node(arel_attribute(key))
        end
        values = @klass.connection.columns_for_distinct(columns, relation.order_values)

        relation = relation.except(:select).select(values).distinct!

        id_rows = skip_query_cache_if_necessary { @klass.connection.select_all(relation.arel, "SQL") }
        # CPK
        #id_rows.map { |row| row[primary_key] }
        id_rows.map do |row|
          @klass.primary_keys.map do |key|
            row[key]
          end
        end
      end

      def construct_relation_for_exists(conditions)
        relation = except(:select, :distinct, :order)._select!(::ActiveRecord::FinderMethods::ONE_AS_ONE).limit!(1)

        case conditions
          # CPK
          when CompositePrimaryKeys::CompositeKeys
            relation = relation.where(cpk_id_predicate(table, primary_key, conditions))
          # CPK
          when Array
            pk_length = @klass.primary_keys.length

            if conditions.length == pk_length # E.g. conditions = ['France', 'Paris']
              return self.construct_relation_for_exists(conditions.to_composite_keys)
            else # Assume that conditions contains where relation
              relation = relation.where(conditions)
            end
          when Array, Hash
            relation.where!(conditions)
          else
            relation.where!(primary_key => conditions) unless conditions == :none
        end

        relation
      end

      def find_with_ids(*ids)
        raise UnknownPrimaryKey.new(@klass) if primary_key.nil?

        # CPK
        # expects_array = ids.first.kind_of?(Array)
        ids = CompositePrimaryKeys.normalize(ids, @klass.primary_keys.length)
        expects_array = ids.flatten != ids.flatten(1)
        return ids.first if expects_array && ids.first.empty?

        # CPK
        # ids = ids.flatten.compact.uniq
        ids = expects_array ? ids.first : ids

        model_name = @klass.name

        case ids.size
          when 0
            error_message = "Couldn't find #{model_name} without an ID"
            raise RecordNotFound.new(error_message, model_name, primary_key)
          when 1
            result = find_one(ids.first)
            expects_array ? [ result ] : result
          else
            find_some(ids)
        end
      rescue ::RangeError
        error_message = "Couldn't find #{model_name} with an out of range ID"
        raise RecordNotFound.new(error_message, model_name, primary_key, ids)
      end

      def last(limit = nil)
        return find_last(limit) if loaded? || limit_value

        result = limit(limit || 1)
        # CPK
        # result.order!(arel_attribute(primary_key)) if order_values.empty? && primary_key
        if order_values.empty? && primary_key
          if composite?
            result.order!(primary_keys.map { |pk| arel_attribute(pk).asc })
          elsif
            result.order!(arel_attribute(primary_key))
          end
        end

        result = result.reverse_order!

        limit ? result.reverse : result.first
      rescue ::ActiveRecord::IrreversibleOrderError
        ActiveSupport::Deprecation.warn(<<-WARNING.squish)
            Finding a last element by loading the relation when SQL ORDER
            can not be reversed is deprecated.
            Rails 5.1 will raise ActiveRecord::IrreversibleOrderError in this case.
            Please call `to_a.last` if you still want to load the relation.
        WARNING
        find_last(limit)
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
        # CPK
        if composite?
          ids = if ids.length == 1
                  CompositePrimaryKeys::CompositeKeys.parse(ids.first)
                else
                  ids.to_composite_keys
                end
        end

        return find_some_ordered(ids) unless order_values.present?

        # CPK
        # result = where(primary_key => ids).to_a
        result = if composite?
          result = where(cpk_in_predicate(table, primary_keys, ids)).to_a
        else
          result = where(primary_key => ids).to_a
        end

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

      def find_some_ordered(ids)
        ids = ids.slice(offset_value || 0, limit_value || ids.size) || []

        # CPK
        # result = except(:limit, :offset).where(primary_key => ids).records
        result = if composite?
          except(:limit, :offset).where(cpk_in_predicate(table, primary_keys, ids)).records
        else
          except(:limit, :offset).where(primary_key => ids).records
        end

        if result.size == ids.size
          pk_type = @klass.type_for_attribute(primary_key)

          records_by_id = result.index_by(&:id)
          # CPK
          # ids.map { |id| records_by_id.fetch(pk_type.cast(id)) }
          if composite?
            ids.map do |id|
              typecasted_id = primary_keys.zip(id).map do |col, val|
                @klass.type_for_attribute(col).cast(val)
              end
              records_by_id.fetch(typecasted_id)
            end
          else
            ids.map { |id| records_by_id.fetch(pk_type.cast(id)) }
          end
        else
          raise_record_not_found_exception!(ids, result.size, ids.size)
        end
      end

      def ordered_relation
        if order_values.empty? && primary_key
          # CPK
          #order(arel_attribute(primary_key).asc)
          order(Array(primary_key).map {|key| arel_attribute(key).asc})
        else
          self
        end
      end
    end
  end
end
