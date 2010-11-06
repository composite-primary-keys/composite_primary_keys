module ActiveRecord
  module Associations
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
  end
end