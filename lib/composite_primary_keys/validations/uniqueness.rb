module ActiveRecord
  module Validations
    class UniquenessValidator
      def validate_each(record, attribute, value)
        finder_class = find_finder_class_for(record)
        table = finder_class.arel_table

        coder = record.class.serialized_attributes[attribute.to_s]

        if value && coder
          value = coder.dump value
        end

        relation = build_relation(finder_class, table, attribute, value)
        # CPK
        # relation = relation.and(table[finder_class.primary_key.to_sym].not_eq(record.send(:id))) if record.persisted?
        if record.persisted?
          not_eq_conditions = Array(finder_class.primary_key).zip(Array(record.send(:id))).map do |name, value|
            table[name.to_sym].not_eq(value)
          end

          condition = not_eq_conditions.shift
          not_eq_conditions.each do |not_eq_condition|
            condition = condition.or(not_eq_condition)
          end
          relation = relation.and(condition)
        end

        Array.wrap(options[:scope]).each do |scope_item|
          scope_value = record.send(scope_item)
          relation = relation.and(table[scope_item].eq(scope_value))
        end

        if finder_class.unscoped.where(relation).exists?
          record.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(:value => value))
        end
      end
    end
  end
end