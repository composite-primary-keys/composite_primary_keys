module ActiveRecord
  module Associations
    class Preloader
      class BelongsTo
        def records_for(ids)
          # CPK
          predicate = cpk_in_predicate(table, association_key_name, ids)
          scoped.where(predicate)
        end
      end
    end
  end
end
