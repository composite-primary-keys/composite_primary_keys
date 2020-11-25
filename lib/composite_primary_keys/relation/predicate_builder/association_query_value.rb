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
    end
  end
end
