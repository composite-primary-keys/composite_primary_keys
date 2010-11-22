module CompositePrimaryKeys
  module ActiveRecord
    module Relation
      module InstanceMethods
        def ids_predicate(id)
          predicate = nil

          if id.kind_of?(CompositePrimaryKeys::CompositeKeys)
            id = [id]
          end

          id.each do |composite_id|
            self.primary_keys.zip(composite_id).each do |key, value|
              eq = table[key].eq(value)
              predicate = predicate ? predicate.and(eq) : eq
            end
          end
          predicate
        end

        def delete(id_or_array)
          # CPK
          # where(@klass.primary_key => id_or_array).delete_all
          where(ids_predicate(id_or_array)).delete_all
        end

        def destroy(id)
          # CPK
          #if id.is_a?(Array)
          #  id.map { |one_id| destroy(one_id) }
          #else
            find(id).destroy
          #end
        end
      end
    end
  end
end