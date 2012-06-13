module ActiveRecord
  module Associations
    class HasAndBelongsToManyAssociation
      def insert_record(record, validate = true, raise = false)
        if record.new_record?
          if raise
            record.save!(:validate => validate)
          else
            return unless record.save(:validate => validate)
          end
        end

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

      def delete_records(records, method)
        if sql = options[:delete_sql]
          records.each { |record| owner.connection.delete(interpolate(sql, record)) }
        else
          relation = join_table
          # CPK
          # stmt = relation.where(relation[reflection.foreign_key].eq(owner.id).
          #  and(relation[reflection.association_foreign_key].in(records.map { |x| x.id }.compact))
          #).compile_delete

          predicate1 = cpk_id_predicate(relation, Array(reflection.foreign_key), Array(owner.id))
          predicate2 = cpk_in_predicate(relation, Array(reflection.association_foreign_key), records.map { |x| x.id }) unless records == :all
          stmt = relation.where(predicate1.and(predicate2)).compile_delete

          owner.connection.delete stmt.to_sql
        end
      end
    end    
  end
end
