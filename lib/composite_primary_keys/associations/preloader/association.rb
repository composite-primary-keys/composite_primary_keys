module ActiveRecord
  module Associations
    class Preloader
      class Association
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

        def load_records
          # owners can be duplicated when a relation has a collection association join
          # #compare_by_identity makes such owners different hash keys
          @records_by_owner = {}.compare_by_identity
          raw_records = owner_keys.empty? ? [] : records_for(owner_keys)

          @preloaded_records = raw_records.select do |record|
            assignments = false

            owners_by_key[convert_key(record[association_key_name])].each do |owner|
              entries = (@records_by_owner[owner] ||= [])

              if reflection.collection? || entries.empty?
                entries << record
                assignments = true
              end
            end

            assignments
          end
        end

      end
    end
  end
end
