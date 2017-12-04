module ActiveRecord
  class PredicateBuilder
    class AssociationQueryValue
      def queries
        # CPK
        if associated_table.association_join_foreign_key.is_a?(Array)
          result = associated_table.association_join_foreign_key.zip(ids).reduce(Hash.new) do |hash, pair|
            hash[pair.first.to_s] = pair.last
            hash
          end
          [result]
        else
          [associated_table.association_join_foreign_key.to_s => ids]
        end
      end
    end
  end
end
