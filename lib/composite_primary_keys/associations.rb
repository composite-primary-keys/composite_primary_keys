module ActiveRecord
  module Associations
    class AssociationProxy
      def full_columns_equals(table_name, keys, quoted_ids)
        quoted_table_name = @owner.connection.quote_table_name(table_name)

        keys = [keys].flatten
        ids = [quoted_ids].flatten

        [keys,ids].transpose.map do |key, id|
        "(#{quoted_table_name}.#{@owner.connection.quote_column_name(key)} = #{id})"
        end.join(' AND ')
      end
  
      def set_belongs_to_association_for(record)
        if @reflection.options[:as]
          record["#{@reflection.options[:as]}_id"]   = @owner.id unless @owner.new_record?
          record["#{@reflection.options[:as]}_type"] = @owner.class.base_class.name.to_s
        else
          unless @owner.new_record?
            primary_key = @reflection.options[:primary_key] || :id
            # CPK
            # record[@reflection.primary_key_name] = @owner.send(primary_key)
            values = [@owner.send(primary_key)].flatten
            key_values = @reflection.cpk_primary_key.zip(values)
            key_values.each {|key, value| record[key] = value}
          end
        end
      end
    end

    class HasAndBelongsToManyAssociation
      def construct_sql
        if @reflection.options[:finder_sql]
          @finder_sql = interpolate_sql(@reflection.options[:finder_sql])
        else
          # CPK
          # @finder_sql = "#{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.primary_key_name} = #{owner_quoted_id} "
          @finder_sql = full_columns_equals(@reflection.options[:join_table], @reflection.cpk_primary_key, owner_quoted_id)
          @finder_sql << " AND (#{conditions})" if conditions
        end

        join_condition = if composite?
          conditions = Array.new
          primary_keys.length.times do |i|
            conditions << "#{@reflection.quoted_table_name}.#{@reflection.klass.primary_key[i]} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key[i]}"
          end
          conditions.join(' AND ')
        else
          "#{@reflection.quoted_table_name}.#{@reflection.klass.primary_key} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key}"
        end
        #@join_sql = "INNER JOIN #{@owner.connection.quote_table_name @reflection.options[:join_table]} ON #{@reflection.quoted_table_name}.#{@reflection.klass.primary_key} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key}"
        @join_sql = "INNER JOIN #{@owner.connection.quote_table_name @reflection.options[:join_table]} ON (#{join_condition})"

        construct_counter_sql
      end
    end

    class HasManyAssociation
      def construct_sql
        case
          when @reflection.options[:finder_sql]
            @finder_sql = interpolate_sql(@reflection.options[:finder_sql])

          when @reflection.options[:as]
            @finder_sql =
              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.name.to_s)}"
            @finder_sql << " AND (#{conditions})" if conditions

          else
            # CPK
            # @finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
            @finder_sql = full_columns_equals(@reflection.quoted_table_name, @reflection.cpk_primary_key, owner_quoted_id)
            @finder_sql << " AND (#{conditions})" if conditions
        end

        construct_counter_sql
      end

      # Deletes the records according to the <tt>:dependent</tt> option.
      def delete_records(records)
        case @reflection.options[:dependent]
          when :destroy
            records.each { |r| r.destroy }
          when :delete_all
            @reflection.klass.delete(records.map { |record| record.id })
          else
            relation = Arel::Table.new(@reflection.table_name)
            # CPK
            # relation.where(relation[@reflection.primary_key_name].eq(@owner.id).
            #    and(Arel::Predicates::In.new(relation[@reflection.klass.primary_key], records.map(&:id)))
            # ).update(relation[@reflection.primary_key_name] => nil)
            id_predicate = nil
            owner_key_values = @reflection.cpk_primary_key.zip([@owner.id].flatten)
            owner_key_values.each do |key, value|
              eq = relation[key].eq(value)
              id_predicate = id_predicate ? id_predicate.and(eq) : eq
            end

            record_predicates = nil
            records.each do |record|
              keys = [@reflection.klass.primary_key].flatten
              values = [record.id].flatten

              record_predicate = nil
              keys.zip(values).each do |key, value|
                eq = relation[key].eq(value)
                record_predicate = record_predicate ? record_predicate.and(eq) : eq
              end
              record_predicates = record_predicates ? record_predicates.or(record_predicate) : record_predicate
            end

            relation = relation.where(id_predicate.and(record_predicates))

            nullify = @reflection.cpk_primary_key.inject(Hash.new) do |hash, key|
              hash[relation[key]] = nil
              hash
            end

            relation.update(nullify)

            @owner.class.update_counters(@owner.id, cached_counter_attribute_name => -records.size) if has_cached_counter?
        end
      end
    end

    class HasOneAssociation
      def construct_sql
        case
          when @reflection.options[:as]
            @finder_sql =
              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.name.to_s)}"
          else
            # CPK
            #@finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
            @finder_sql = full_columns_equals(@reflection.quoted_table_name, @reflection.cpk_primary_key, owner_quoted_id)
        end
        @finder_sql << " AND (#{conditions})" if conditions
      end
    end

    class JoinDependency
      class JoinBase
        def column_names_with_alias
          unless defined?(@column_names_with_alias)
            @column_names_with_alias = []
            keys = active_record.composite? ? primary_key.map(&:to_s) : [primary_key]
            (keys + (column_names - keys)).each_with_index do |column_name, i|
              @column_names_with_alias << [column_name, "#{ aliased_prefix }_r#{ i }"]
            end
          end
          @column_names_with_alias
        end
      end
    end
  end
end