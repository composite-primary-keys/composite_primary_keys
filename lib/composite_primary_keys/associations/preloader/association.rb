module ActiveRecord
  module Associations
    class Preloader
      class Association

        class LoaderQuery
          def load_records_for_keys(keys, &block)
            # CPK
            if association_key_name.is_a?(Array)
              predicate = cpk_in_predicate(scope.klass.arel_table, association_key_name, keys)
              scope.where(predicate).load(&block)
            else
              scope.where(association_key_name => keys).load(&block)
            end
          end
        end

        # TODO: is records_for needed anymore? Rails' implementation has changed significantly
        def records_for(ids)
          records = if association_key_name.is_a?(Array)
                      predicate = cpk_in_predicate(klass.arel_table, association_key_name, ids)
                      scope.where(predicate)
                    else
                      scope.where(association_key_name => ids)
                    end
          records.load do |record|
            # Processing only the first owner
            # because the record is modified but not an owner
            owner = owners_by_key[convert_key(record[association_key_name])].first
            association = owner.association(reflection.name)
            association.set_inverse_instance(record)
          end
        end

        def owners_by_key
          @owners_by_key ||= owners.each_with_object({}) do |owner, result|
            # CPK
            # key = convert_key(owner[owner_key_name])
            key = if owner_key_name.is_a?(Array)
                    Array(owner_key_name).map do |key_name|
                      convert_key(owner[key_name])
                    end
                  else
                    convert_key(owner[owner_key_name])
                  end
            (result[key] ||= []) << owner if key
          end
        end

        # TODO: is records_by_owner needed anymore? Rails' implementation has changed significantly
        def records_by_owner
          @records_by_owner ||= preloaded_records.each_with_object({}) do |record, result|
            key = if association_key_name.is_a?(Array)
                    Array(record[association_key_name]).map do |key|
                      convert_key(key)
                    end
                  else
                    convert_key(record[association_key_name])
                  end
            owners_by_key[key].each do |owner|
              (result[owner] ||= []) << record
            end
          end
        end
      end
    end
  end
end
