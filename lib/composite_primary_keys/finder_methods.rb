module CompositePrimaryKeys
  module ActiveRecord
    module FinderMethods
      module InstanceMethods
        def exists?(id = nil)
          case id
          when Array
            # CPK
            if id.first.is_a?(String) and id.first.match(/\?/)
              where(id).exists?
            else
              where(ids_predicate(id)).exists?
            end
          when Hash
            where(id).exists?
          else
            relation = select(primary_key).limit(1)
            # CPK
            #relation = relation.where(primary_key.eq(id)) if id
            relation = relation.where(ids_predicate(id)) if id
            relation.first ? true : false
          end
        end

        def find_with_ids(*ids, &block)
          return to_a.find(&block) if block_given?

          ids = ids.first if ids.last == nil

          # if ids is just a flat list, then its size must = primary_key.length (one id per primary key, in order)
          # if ids is list of lists, then each inner list must follow rule above
          if ids.first.is_a? String
            # find '2,1' -> ids = ['2,1']
            # find '2,1;7,3' -> ids = ['2,1;7,3']
            match = ids.first.match(/^\[(.*)\]$/)
            ids = (match ? match[1] : ids.first).split(ID_SET_SEP).map {|id_set| id_set.split(CompositePrimaryKeys::ID_SEP).to_composite_ids}
            # find '2,1;7,3' -> ids = [['2','1'],['7','3']], inner [] are CompositeIds
          end

          ids = [ids.to_composite_ids] if not ids.first.kind_of?(Array)

          ids.each do |id_set|
            unless id_set.is_a?(Array)
              raise "Ids must be in an Array, instead received: #{id_set.inspect}"
            end
            unless id_set.length == @klass.primary_keys.length
              raise "#{id_set.inspect}: Incorrect number of primary keys for #{@klass.name}: #{@klass.primary_keys.inspect}"
            end
          end

          new_relation = clone
          ids.each do |id_set|
            [@klass.primary_keys, id_set].transpose.map do |key, id|
              new_relation = new_relation.where(key => id)
            end
          end

          result = new_relation.to_a

          if result.size == ids.size
            ids.size == 1 ? result[0] : result
          else
            raise ::ActiveRecord::RecordNotFound, "Couldn't find all #{@klass.name} with IDs (#{ids.inspect})"
          end
        end
      end
    end
  end
end
