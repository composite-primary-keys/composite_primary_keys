module ActiveRecord
  module Associations
    class HasManyAssociation
#      def construct_sql
#        case
#          when @reflection.options[:finder_sql]
#            @finder_sql = interpolate_and_sanitize_sql(@reflection.options[:finder_sql])
#
#          when @reflection.options[:as]
#            @finder_sql =
#              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
#              "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.name.to_s)}"
#            @finder_sql << " AND (#{conditions})" if conditions
#
#          else
#            # CPK
#            # @finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
#            @finder_sql = full_columns_equals(@reflection.table_name, @reflection.cpk_primary_key, owner_quoted_id)
#            @finder_sql << " AND (#{conditions})" if conditions
#        end
#
#        construct_counter_sql
#      end
#
#      def owner_quoted_id
#        if (keys = @reflection.options[:primary_key])
#          keys.is_a?(Array) ? keys.collect {|k| quote_value(@owner.send(k)) } : quote_value(@owner.send(keys))
#        else
#          @owner.quoted_id
#        end
#      end
#
      def delete_records(records, method)
        if method == :destroy
          records.each { |r| r.destroy }
          update_counter(-records.length) unless inverse_updates_counter_cache?
        else
          # CPK
          # keys  = records.map { |r| r[reflection.association_primary_key] }
          # scope = scoped.where(reflection.association_primary_key => keys)
          table = Arel::Table.new(reflection.table_name)
          and_conditions = records.map do |record|
            eq_conditions = Array(reflection.association_primary_key).map do |name|
              table[name].eq(record[name])
            end
            Arel::Nodes::And.new(eq_conditions)
          end

          condition = and_conditions.shift
          and_conditions.each do |and_condition|
            condition = condition.or(and_condition)
          end

          scope = scoped.where(condition)

          if method == :delete_all
            update_counter(-scope.delete_all)
          else
            # CPK
            # update_counter(-scope.update_all(reflection.foreign_key => nil))
            updates = Array(reflection.foreign_key).inject(Hash.new) do |hash, name|
              hash[name] = nil
              hash
            end
            update_counter(-scope.update_all(updates))
          end
        end
      end
    end
  end
end
