module ActiveRecord
  module Persistence
    module ClassMethods
      def delete(id_or_array)
        # CPK
        if self.composite?
          id_or_array = if id_or_array.is_a?(CompositePrimaryKeys::CompositeKeys)
                          [id_or_array]
                        else
                          Array(id_or_array)
                        end

          id_or_array.each do |id|
            # Is the passed in id actually a record?
            id = id.kind_of?(::ActiveRecord::Base) ? id.id : id
            delete_by(cpk_id_predicate(self.arel_table, self.primary_key, id))
          end
        else
          delete_by(primary_key => id_or_array)
        end
      end

      def _update_record(values, constraints) # :nodoc:
        # CPK
        if self.composite? && constraints[primary_key]
          primary_key_values = constraints.delete(primary_key)
          primary_key.each_with_index do |key, i|
           constraints[key] = primary_key_values[i]
          end
        end

        constraints = _substitute_values(constraints).map { |attr, bind| attr.eq(bind) }

        um = arel_table.where(
          constraints.reduce(&:and)
        ).compile_update(_substitute_values(values), primary_key)

        connection.update(um, "#{self} Update")
      end

      def _delete_record(constraints) # :nodoc:
        # CPK
        if self.composite? && constraints[primary_key]
          primary_key_values = constraints.delete(primary_key)
          primary_key.each_with_index do |key, i|
            constraints[key] = primary_key_values[i]
          end
        end

        constraints = _substitute_values(constraints).map { |attr, bind| attr.eq(bind) }

        dm = Arel::DeleteManager.new
        dm.from(arel_table)
        dm.wheres = constraints

        connection.delete(dm, "#{self} Destroy")
      end
    end

    def _create_record(attribute_names = self.attribute_names)
      attribute_names = attributes_for_create(attribute_names)

      new_id = self.class._insert_record(
          attributes_with_values(attribute_names)
      )

      # CPK
      if self.composite? && self.id.compact.empty?
        self.id = self.id.zip(Array(new_id)).map {|id1, id2| (id1 || id2)}
      else
        self.id ||= new_id if self.class.primary_key
      end

      @new_record = false

      yield(self) if block_given?

      id
    end
  end
end
