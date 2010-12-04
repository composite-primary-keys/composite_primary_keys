module ActiveRecord
  module Validations
    class UniquenessValidator
      def validate_each(record, attribute, value)
        finder_class = find_finder_class_for(record)
        table = finder_class.unscoped

        table_name   = record.class.quoted_table_name

        if value && record.class.serialized_attributes.key?(attribute.to_s)
          value = YAML.dump value
        end

        sql, params  = mount_sql_and_params(finder_class, table_name, attribute, value)

        relation = table.where(sql, *params)

        Array.wrap(options[:scope]).each do |scope_item|
          scope_value = record.send(scope_item)
          relation = relation.where(scope_item => scope_value)
        end

        if record.persisted?
          # CPK
          if record.composite?
            predicate = nil
            record.ids_hash.each do |key, value|
              neq = relation.table[key].not_eq(value)
              predicate = predicate ? predicate.and(neq) : neq
            end
            relation = relation.where(predicate)
          else
            # TODO : This should be in Arel
            relation = relation.where("#{record.class.quoted_table_name}.#{record.class.primary_key} <> ?", record.send(:id))
          end
        end

        if relation.exists?
          record.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(:value => value))
        end
      end
    end
  end
end