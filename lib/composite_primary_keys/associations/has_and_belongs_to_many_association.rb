module ActiveRecord
  module Associations
    class HasAndBelongsToManyAssociation
      def insert_record(record, validate = true)
        return if record.new_record? && !record.save(:validate => validate)

        if options[:insert_sql]
          owner.connection.insert(interpolate(options[:insert_sql], record))
        else
          # CPK
          #stmt = join_table.compile_insert(
          #  join_table[reflection.foreign_key]             => owner.id,
          #  join_table[reflection.association_foreign_key] => record.id
          #)
          join_values = Hash.new
          Array(reflection.foreign_key).zip(Array(owner.id)) do |name, value|
            attribute = join_table[name]
            join_values[attribute] = value
          end

          Array(reflection.association_foreign_key).zip(Array(record.id)) do |name, value|
            attribute = join_table[name]
            join_values[attribute] = value
          end

          stmt = join_table.compile_insert(join_values)

          owner.connection.insert stmt.to_sql
        end

        record
      end
    end
  end
end