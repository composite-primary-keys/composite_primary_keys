module ActiveRecord
  class PredicateBuilder
    class AssociationQueryValue
      def queries
        # CPK
        if associated_table.association_join_foreign_key.is_a?(Array)
          if ids.is_a?(ActiveRecord::Relation)
            ids.map do |id|
              id.ids_hash
            end
          else
            [associated_table.association_join_foreign_key.zip(ids).to_h]
          end
        else
          [associated_table.association_join_foreign_key.to_s => ids]
        end
      end
    end
  end
end
