module CompositePrimaryKeys
  module ActiveRecord
    module FinderMethods
      def construct_limited_ids_condition(relation)
        orders = relation.order_values
        # CPK
        # values = @klass.connection.distinct("#{@klass.connection.quote_table_name table_name}.#{primary_key}", orders)
        keys = @klass.primary_keys.map do |key|
          "#{@klass.connection.quote_table_name @klass.table_name}.#{key}"
        end
        values = @klass.connection.distinct(keys.join(', '), orders)

        relation = relation.dup

        ids_array = relation.select(values).collect {|row| row[primary_key]}
        # CPK
        # ids_array.empty? ? raise(ThrowResult) : table[primary_key].in(ids_array)

        # OR together each and expression (key=value and key=value) that matches an id set
        # since we only need to match 0 or more records
        or_expressions = ids_array.map do |id_set|
          # AND together "key=value" exprssios to match each id set
          and_expressions = [self.primary_keys, id_set].transpose.map do |key, id|
            table[key].eq(id)
          end
          Arel::Nodes::And.new(and_expressions)
        end

        first = or_expressions.shift
        Arel::Nodes::Grouping.new(or_expressions.inject(first) do |memo, expr|
            Arel::Nodes::Or.new(memo, expr)
        end)
      end

      def exists?(id = nil)
        # ID can be:
        #   Array - ['department_id = ? and location_id = ?', 1, 1]
        #   Array -> [1,2]
        #   CompositeKeys -> [1,2]

        id = id.id if ::ActiveRecord::Base === id

        join_dependency = construct_join_dependency_for_association_find
        relation = construct_relation_for_association_find(join_dependency)
        relation = relation.except(:select).select("1").limit(1)

        # CPK
        #case id
        #when Array, Hash
        #  relation = relation.where(id)
        #else
        #  relation = relation.where(table[primary_key].eq(id)) if id
        #end

        case id
        when CompositePrimaryKeys::CompositeKeys
          relation = relation.where(cpk_id_predicate(table, primary_key, id))
        when Array
          pk_length = @klass.primary_keys.length

          if id.length == pk_length # E.g. id = ['France', 'Paris']
            return self.exists?(id.to_composite_keys)
          else # Assume that id contains where relation
            relation = relation.where(id)
          end
        when Hash
          relation = relation.where(id)
        end
        connection.select_value(relation.to_sql) ? true : false
      end

      def find_with_ids(*ids, &block)
        return to_a.find { |*block_args| yield(*block_args) } if block_given?

        # Supports:
        #   find('1,2')             ->  ['1,2']
        #   find(1,2)               ->  [1,2]
        #   find([1,2])             -> [['1,2']]
        #   find([1,2], [3,4])      -> [[1,2],[3,4]]
        #
        # Does *not* support:
        #   find('1,2', '3,4')      ->  ['1,2','3,4']

        # Normalize incoming data.  Note the last arg can be nil.  Happens
        # when find is called with nil options which is then passed on
        # to find_with_ids.
        ids.compact!

        ids = [ids] unless ids.first.kind_of?(Array)

        results = ids.map do |cpk_ids|
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

        ids.length == 1 ? results.first : results
      end
    end
  end
end