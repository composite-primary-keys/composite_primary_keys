module ActiveRecord
  module Associations
    class JoinDependency
      def instantiate(rows)
        primary_key = join_base.aliased_primary_key
        parents = {}

        records = rows.map { |model|
          # CPK
          #primary_id = model[primary_key]
          primary_id = if primary_key.kind_of?(Array)
            primary_key.map {|key| model[key]}
          else
            model[primary_key]
          end
          parent = parents[primary_id] ||= join_base.instantiate(model)
          construct(parent, @associations, join_associations, model)
          parent
        }.uniq

        remove_duplicate_results!(active_record, records, @associations)
        records
      end
    end
  end
end