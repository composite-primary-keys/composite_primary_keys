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
            #limited_ids.empty? ? relation.none! : relation.where!(table[primary_key].in(limited_ids))
            limited_ids.empty? ? relation.none! : relation.where!(cpk_in_predicate(table, self.primary_keys, limited_ids))
          end
          relation.except(:limit, :offset)
        end
      end

      def limited_ids_for(relation)
        # CPK
        #values = @klass.connection.columns_for_distinct(
        #  "#{quoted_table_name}.#{quoted_primary_key}", relation.order_values)
        columns = @klass.primary_keys.map do |key|
          "#{quoted_table_name}.#{connection.quote_column_name(key)}"
        end
        values = @klass.connection.columns_for_distinct(columns, relation.order_values)

        relation = relation.except(:select).select(values).distinct!

        id_rows = @klass.connection.select_all(relation.arel, 'SQL', relation.bind_values)

        # CPK
        #id_rows.map {|row| row[primary_key]}
        id_rows.map {|row| row.values}
      end

      def exists?(conditions = :none)
        # conditions can be:
        #   Array - ['department_id = ? and location_id = ?', 1, 1]
        #   Array -> [1,2]
        #   CompositeKeys -> [1,2]

        conditions = conditions.id if ::ActiveRecord::Base === conditions
        return false if !conditions

        relation = apply_join_dependency(self, construct_join_dependency)
        return false if ::ActiveRecord::NullRelation === relation

        relation = relation.except(:select, :order).select(::ActiveRecord::FinderMethods::ONE_AS_ONE).limit(1)

        # CPK
        #case conditions
        #when Array, Hash
        #  relation = relation.where(conditions)
        #else
        #  relation = relation.where(table[primary_key].eq(conditions)) if conditions != :none
        #end

        case conditions
        when CompositePrimaryKeys::CompositeKeys
          relation = relation.where(cpk_id_predicate(table, primary_key, conditions))
        when Array
          pk_length = @klass.primary_keys.length

          if conditions.length == pk_length # E.g. conditions = ['France', 'Paris']
            return self.exists?(conditions.to_composite_keys)
          else # Assume that conditions contains where relation
            relation = relation.where(conditions)
          end
        when Hash
          relation = relation.where(conditions)
        end

        connection.select_value(relation, "#{name} Exists", relation.bind_values) ? true : false
      end

      def find_with_ids(*ids)
        # CPK handle strings that come w/ calling to_param on CPK-enabled models
        ids = parse_ids(ids)
        raise UnknownPrimaryKey.new(@klass) if primary_key.nil?

        expects_array = ids.first.kind_of?(Array)
        return ids.first if expects_array && ids.first.empty?

        # CPK - don't do this, we want an array of arrays
        #ids = ids.flatten.compact.uniq
        case ids.size
          when 0
            raise RecordNotFound, "Couldn't find #{@klass.name} without an ID"
          when 1
            result = find_one(ids.first)
            # CPK
            # expects_array ? [ result ] : result
            result
          else
            find_some(ids)
        end
      end

      def find_one(id)
        # CPK
        #id = id.id if ActiveRecord::Base === id
        id = id.id if ::ActiveRecord::Base === id

        # CPK
        #column = columns_hash[primary_key]
        #substitute = connection.substitute_at(column, bind_values.length)
        #relation = where(table[primary_key].eq(substitute))
        #relation.bind_values += [[column, id]]
        #record = relation.take
        relation = self
        relation = relation.where(cpk_id_predicate(table, primary_keys, id))

        record = relation.take
        raise_record_not_found_exception!(id, 0, 1) unless record
        record
      end

      def find_some(ids)
        # CPK
        # result = where(table[primary_key].in(ids)).to_a

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

      private
      def parse_ids(ids)
        result = []
        ids.each do |id|
          if id.is_a?(String)
            if id.index(",")
              result << [id.split(",")]
            else
              result << [id]
            end
          elsif id.is_a?(Array) && id.count > 1 && id.first.to_s.index(",")
            result << id.map{|subid| subid.split(",")}
          else
            result << [id]
          end
        end
        result = result.flatten(1)
        return result
      end
    end
  end
end
