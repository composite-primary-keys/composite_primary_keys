module ActiveRecord
  module Associations
    class Preloader
      class Association
        def records_for(ids)
          # CPK
          # scoped.where(association_key.in(ids))
          predicate = cpk_in_predicate(table, reflection.foreign_key, ids)
          scoped.where(predicate)
        end
        
        def associated_records_by_owner
          # CPK
          owners_map = owners_by_key
          #owner_keys = owners_map.keys.compact
          owner_keys = owners.map do |owner|
            Array(owner_key_name).map do |owner_key|
              owner[owner_key]
            end
          end.compact.uniq

          if klass.nil? || owner_keys.empty?
            records = []
          else
            # Some databases impose a limit on the number of ids in a list (in Oracle it's 1000)
            # Make several smaller queries if necessary or make one query if the adapter supports it
            sliced  = owner_keys.each_slice(model.connection.in_clause_length || owner_keys.size)
            records = sliced.map { |slice| records_for(slice) }.flatten
          end

          # Each record may have multiple owners, and vice-versa
          records_by_owner = Hash[owners.map { |owner| [owner, []] }]
          records.each do |record|
            # CPK
            # owner_key = record[association_key_name].to_s
            owner_key = Array(association_key_name).map do |key_name|
              record[key_name]
            end.join(CompositePrimaryKeys::ID_SEP)

            owners_map[owner_key].each do |owner|
              records_by_owner[owner] << record
            end
          end
          records_by_owner
        end

        def owners_by_key
          @owners_by_key ||= owners.group_by do |owner|
            # CPK
            # key = owner[owner_key_name]
            key = Array(owner_key_name).map do |key_name|
              owner[key_name]
            end
            # CPK
            # key && key.to_s
            key && key.join(CompositePrimaryKeys::ID_SEP)
          end
        end
      end
    end
  end
end