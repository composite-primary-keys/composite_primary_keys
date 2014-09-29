module ActiveRecord
  module Validations
    class UniquenessValidator
      def validate_each(record, attribute, value)
        finder_class = find_finder_class_for(record)
        table = finder_class.arel_table
        value = map_enum_attribute(finder_class, attribute, value)

        relation = build_relation(finder_class, table, attribute, value)
        # CPK
        # relation = relation.and(table[finder_class.primary_key.to_sym].not_eq(record.id)) if record.persisted?
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
        
        relation = scope_relation(record, table, relation)
        relation = finder_class.unscoped.where(relation)
        relation = relation.merge(options[:conditions]) if options[:conditions]

        if relation.exists?
          error_options = options.except(:case_sensitive, :scope, :conditions)
          error_options[:value] = value

          record.errors.add(attribute, :taken, error_options)
        end
      end
    end
  end
end