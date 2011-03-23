module ActiveRecord
  module Associations
    class HasManyAssociation
      def construct_sql
        case
          when @reflection.options[:finder_sql]
            @finder_sql = interpolate_and_sanitize_sql(@reflection.options[:finder_sql])

          when @reflection.options[:as]
            @finder_sql =
              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.name.to_s)}"
            @finder_sql << " AND (#{conditions})" if conditions

          else
            # CPK
            # @finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
            @finder_sql = full_columns_equals(@reflection.table_name, @reflection.cpk_primary_key, owner_quoted_id)
            @finder_sql << " AND (#{conditions})" if conditions
        end

        construct_counter_sql
      end

      def owner_quoted_id
        if (keys = @reflection.options[:primary_key])
          keys.is_a?(Array) ? keys.collect {|k| quote_value(@owner.send(k)) } : quote_value(@owner.send(keys))
        else
          @owner.quoted_id
        end
      end

      def delete_records(records)
        case @reflection.options[:dependent]
          when :destroy
            records.each { |r| r.destroy }
          when :delete_all
            @reflection.klass.delete(records.map { |record| record.id })
          else
            relation = Arel::Table.new(@reflection.table_name)
            # CPK
            #relation.where(relation[@reflection.primary_key_name].eq(@owner.id).
            #    and(relation[@reflection.klass.primary_key].in(records.map { |r| r.id }))
            #).update(relation[@reflection.primary_key_name] => nil)

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

            nullify_relation = Arel::Table.new(@reflection.table_name)
            nullify = @reflection.cpk_primary_key.inject(Hash.new) do |hash, key|
              hash[nullify_relation[key]] = nil
              hash
            end

            relation.update(nullify)

            @owner.class.update_counters(@owner.id, cached_counter_attribute_name => -records.size) if has_cached_counter?
        end
      end
    end
  end
end
