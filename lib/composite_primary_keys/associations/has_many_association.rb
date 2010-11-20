module ActiveRecord
  module Associations
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
            @finder_sql = full_columns_equals(@reflection.table_name, @reflection.cpk_primary_key, owner_quoted_id)
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
  end
end