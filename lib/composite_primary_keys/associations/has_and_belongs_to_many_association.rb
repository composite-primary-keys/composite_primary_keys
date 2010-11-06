module ActiveRecord
  module Associations
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
  end
end