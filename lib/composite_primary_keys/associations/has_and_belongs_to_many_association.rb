module ActiveRecord
  module Associations
    class HasAndBelongsToManyAssociation
      def construct_sql
        if @reflection.options[:finder_sql]
          @finder_sql = interpolate_and_sanitize_sql(@reflection.options[:finder_sql])
        else
          # CPK
          # @finder_sql = "#{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.primary_key_name} = #{owner_quoted_id} "
          @finder_sql = full_columns_equals(@reflection.options[:join_table], @reflection.cpk_primary_key, owner_quoted_id)
          @finder_sql << " AND (#{conditions})" if conditions
        end

        join_condition = if composite?
          conditions = Array.new
          primary_keys.length.times do |i|
            conditions << "#{@reflection.quoted_table_name}.#{@reflection.klass.primary_key[i]} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key[i]}"
          end
          conditions.join(' AND ')
        else
          "#{@reflection.quoted_table_name}.#{@reflection.klass.primary_key} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key}"
        end
        #@join_sql = "INNER JOIN #{@owner.connection.quote_table_name @reflection.options[:join_table]} ON #{@reflection.quoted_table_name}.#{@reflection.klass.primary_key} = #{@owner.connection.quote_table_name @reflection.options[:join_table]}.#{@reflection.association_foreign_key}"
        @join_sql = "INNER JOIN #{@owner.connection.quote_table_name @reflection.options[:join_table]} ON (#{join_condition})"

        construct_counter_sql
      end
      
      def insert_record(record, force = true, validate = true)
        unless record.persisted?
          if force
            record.save!
          else
            return false unless record.save(:validate => validate)
          end
        end

        if @reflection.options[:insert_sql]
          @owner.connection.insert(interpolate_and_sanitize_sql(@reflection.options[:insert_sql], record))
        else
          relation   = Arel::Table.new(@reflection.options[:join_table])
          timestamps = record_timestamp_columns(record)
          timezone   = record.send(:current_time_from_proper_timezone) if timestamps.any?

          # CPK
          #attributes = Hash[columns.map do |column|
          #  name = column.name
          #  value = case name.to_s
          #    when @reflection.primary_key_name.to_s
          #      @owner.id
          #    when @reflection.association_foreign_key.to_s
          #      record.id
          #    when *timestamps
          #      timezone
          #    else
          #      @owner.send(:quote_value, record[name], column) if record.has_attribute?(name)
          #  end
          #  [relation[name], value] unless value.nil?
          #end]

          # CPK
          owner_foreign_keys = @reflection.cpk_primary_key.map{|key| key.to_s}
          association_foreign_keys = Array(@reflection.association_foreign_key).map{|key| key.to_s}

          attributes = Hash[columns.map do |column|
            name = column.name.to_s
            value = case
              when owner_foreign_keys.include?(name)
                index = owner_foreign_keys.index(name)
                primary_keys = Array(@owner.class.primary_key)
                primary_key = primary_keys[index]
                @owner[primary_key]
              when association_foreign_keys.include?(name)
                index = association_foreign_keys.index(name)
                primary_keys = Array(@reflection.klass.primary_key)
                primary_key = primary_keys[index]
                record[primary_key]
              when timestamps.include?(name)
                timezone
              else
                @owner.send(:quote_value, record[name], column) if record.has_attribute?(name)
            end
            [relation[name], value] unless value.nil?
          end]

          relation.insert(attributes)
        end

        return true
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

          if @reflection.cpk_primary_key.size > 1 
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
