module ActiveRecord
  module Associations
    class HasManyAssociation
      silence_warnings do
        def delete_count(method, scope)
          if method == :delete_all
            scope.delete_all
          else
            # CPK
            # scope.update_all(reflection.foreign_key => nil)
            conds = Array(reflection.foreign_key).inject(Hash.new) do |mem, key|
              mem[key] = nil
              mem
            end
            scope.update_all(conds)
          end
        end

        def foreign_key_present?
          if reflection.klass.primary_key
            # CPK
            # owner.attribute_present?(reflection.association_primary_key)
            Array(reflection.klass.primary_key).all? {|key| owner.attribute_present?(key)}
          else
            false
          end
        end
      end
    end
  end
end
