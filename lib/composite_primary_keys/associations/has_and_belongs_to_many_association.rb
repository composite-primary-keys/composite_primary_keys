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

      # CPK
      #def delete_records(records)
      #  if sql = @reflection.options[:delete_sql]
      #    records.each { |record| @owner.connection.delete(interpolate_and_sanitize_sql(sql, record)) }
      #  else
      #    relation = Arel::Table.new(@reflection.options[:join_table])
      #    relation.where(relation[@reflection.primary_key_name].eq(@owner.id).
      #      and(relation[@reflection.association_foreign_key].in(records.map { |x| x.id }.compact))
      #    ).delete
      #  end
      #end

      # CPK
      def delete_records(records)
        if sql = @reflection.options[:delete_sql]
          records.each { |record| @owner.connection.delete(interpolate_and_sanitize_sql(sql, record)) }
        else
          relation = Arel::Table.new(@reflection.options[:join_table])

          if @reflection.cpk_primary_key 
            owner_conditions = []
            @reflection.cpk_primary_key.each_with_index do |column,i|
              owner_conditions << relation[column.to_sym].eq(@owner.id[i])
            end
            owner_conditions_arel = owner_conditions.inject { |conds, cond| conds.and(cond) }
          else
            owner_conditions_arel = relation[@reflection.primary_key_name].eq(@owner.id)
          end

          if @reflection.association_foreign_key.kind_of?(Array)
            association_conditions = []
            records.each do |rec|
              record_conditions = []
              @reflection.association_foreign_key.each_with_index do |column,i|
                record_conditions << relation[column.to_sym].eq(rec.id[i])
              end
              association_conditions << record_conditions.inject { |conds, cond| conds.and(cond) }
            end
            association_conditions_arel = association_conditions.inject { |conds, cond| conds.or(cond) }
          else
            association_conditions_arel = relation[@reflection.association_foreign_key].in(records.map { |x| x.id }.compact)
          end
          
          all_conditions_arel = owner_conditions_arel.and(association_conditions_arel)
          
          relation.where(all_conditions_arel).delete
        end
      end

    end    
  end
end
