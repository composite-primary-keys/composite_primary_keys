module CompositePrimaryKeys
  module ActiveRecord
    module Relation
      module InstanceMethods
        def where_cpk_id(id)
          relation = clone

          predicates = self.primary_keys.zip(Array(id)).map do |key, value|
            table[key].eq(value)
          end
          relation.where_values += predicates
          relation
        end

        def delete(id_or_array)
          # CPK
          # where(@klass.primary_key => id_or_array).delete_all

          id_or_array = if id_or_array.kind_of?(CompositePrimaryKeys::CompositeKeys)
            [id_or_array]
          else
            Array(id_or_array)
          end

          id_or_array.each do |id|
            where_cpk_id(id).delete_all
          end
        end

        def destroy(id_or_array)
          # CPK
          #if id.is_a?(Array)
          #  id.map { |one_id| destroy(one_id) }
          #else
          #  find(id).destroy
          #end
          id_or_array = if id_or_array.kind_of?(CompositePrimaryKeys::CompositeKeys)
            [id_or_array]
          else
            Array(id_or_array)
          end

          id_or_array.each do |id|
            where_cpk_id(id).each do |record|
              record.destroy
            end
          end
        end
      end
    end
  end
end