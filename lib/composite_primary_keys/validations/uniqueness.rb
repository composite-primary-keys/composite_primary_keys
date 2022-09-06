module ActiveRecord
  module Validations
    class UniquenessValidator
      def validate_each(record, attribute, value)
        finder_class = find_finder_class_for(record)
        value = map_enum_attribute(finder_class, attribute, value)

        relation = build_relation(finder_class, attribute, value)
        if record.persisted?
          # CPK
          if finder_class.primary_key.is_a?(Array)
            predicate = finder_class.cpk_id_predicate(finder_class.arel_table, finder_class.primary_key, record.id_in_database || record.id)
            relation = relation.where.not(predicate)
          elsif finder_class.primary_key
            relation = relation.where.not(finder_class.primary_key => record.id_in_database)
          else
            raise UnknownPrimaryKey.new(finder_class, "Can not validate uniqueness for persisted record without primary key.")
          end
        end
        relation = scope_relation(record, relation)
        if options[:conditions]
          conditions = options[:conditions]

          relation = if conditions.arity.zero?
            relation.instance_exec(&conditions)
          else
            relation.instance_exec(record, &conditions)
          end
        end

        if relation.exists?
          error_options = options.except(:case_sensitive, :scope, :conditions)
          error_options[:value] = value

          record.errors.add(attribute, :taken, **error_options)
        end
      end
    end
  end
end
