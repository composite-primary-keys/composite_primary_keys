module ActiveRecord
  class PredicateBuilder
    class AssociationQueryValue
      def queries
        # CPK
        if associated_table.join_foreign_key.is_a?(Array)
          if ids.is_a?(ActiveRecord::Relation)
            ids.map do |id|
              associated_table.join_foreign_key.zip(id.id).to_h
            end
          else
            [associated_table.join_foreign_key.zip(ids).to_h]
          end
        else
          [associated_table.join_foreign_key => ids]
        end
      end

      def ids
        case value
        when Relation
          value.select_values.empty? ? value.select(primary_key) : value
        when Array
          value.map { |v| convert_to_id(v) }
        else
          # CPK
          # convert_to_id(value)
          if value.nil?
            nil
          elsif value.respond_to?(:composite?) && value.composite?
            value.class.primary_keys.zip(value.id)
          else
            convert_to_id(value)
          end
        end
      end
    end
  end
end
