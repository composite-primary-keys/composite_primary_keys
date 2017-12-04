module ActiveRecord
  module Associations
    class Preloader
      class Association
        def records_for(ids, &block)
          # CPK
          #scope.where(association_key_name => ids).load(&block)

          if association_key_name.is_a?(Array)
            predicate = cpk_in_predicate(klass.arel_table, association_key_name, ids)
            scope.where(predicate).load(&block)
          else
            scope.where(association_key_name => ids).load(&block)
          end
        end

        def associated_records_by_owner(preloader)
          owners_map = owners_by_key
          # CPK
          # owner_keys = owners_map.keys.compact
          owner_keys = if reflection.foreign_key.is_a?(Array)
            owners.map do |owner|
              Array(owner_key_name).map do |owner_key|
                owner[owner_key]
              end
            end.compact.uniq
          else
            owners_map.keys.compact
          end

          # Each record may have multiple owners, and vice-versa
          records_by_owner = owners.each_with_object({}) do |owner,h|
            h[owner] = []
          end

          if owner_keys.any?
            # Some databases impose a limit on the number of ids in a list (in Oracle it's 1000)
            # Make several smaller queries if necessary or make one query if the adapter supports it
            sliced  = owner_keys.each_slice(klass.connection.in_clause_length || owner_keys.size)

            records = load_slices sliced
            records.each do |record, owner_key|
              owners_map[owner_key].each do |owner|
                records_by_owner[owner] << record
              end
            end
          end

          records_by_owner
        end

        def load_slices(slices)
          @preloaded_records = slices.flat_map { |slice|
            records_for(slice)
          }

          # CPK
          # @preloaded_records.map { |record|
          #   key = record[association_key_name]
          #   key = key.to_s if key_conversion_required?
          #
          #   [record, key]
          # }
          @preloaded_records.map { |record|
            key = Array(association_key_name).map do |key_name|
              record[key_name]
            end.join(CompositePrimaryKeys::ID_SEP)

            [record, key]
          }
        end

        def owners_by_key
          unless defined?(@owners_by_key)
            @owners_by_key = owners.each_with_object({}) do |owner, h|
              # CPK
              #key = convert_key(owner[owner_key_name])
              key = if owner_key_name.is_a?(Array)
                      Array(owner_key_name).map do |key_name|
                        convert_key(owner[key_name])
                      end
                    else
                      convert_key(owner[owner_key_name])
                    end

              h[key] = owner if key
            end
          end
          @owners_by_key
        end

        def run(preloader)
          records = load_records do |record|
            # CPK
            #owner = owners_by_key[convert_key(record[association_key_name])]

            key = if association_key_name.is_a?(Array)
                    Array(record[association_key_name]).map do |key|
                      convert_key(key)
                    end
                  else
                    record[association_key_name]
                  end

            owner = owners_by_key[key]
            association = owner.association(reflection.name)
            association.set_inverse_instance(record)
          end

          owners.each do |owner|
            associate_records_to_owner(owner, records[convert_key(owner[owner_key_name])] || [])
          end
        end
      end
    end
  end
end
