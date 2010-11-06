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
  end
end