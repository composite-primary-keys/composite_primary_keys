module CompositePrimaryKeys
  module ActiveRecord
    module AssociationPreload
      def self.append_features(base)
        super
        base.send(:extend, ClassMethods)
      end

      # Composite key versions of Association functions
      module ClassMethods
        def preload_has_and_belongs_to_many_association(records, reflection, preload_options={})
          table_name = reflection.klass.quoted_table_name
          id_to_record_map, ids = construct_id_map(records)
          records.each {|record| record.send(reflection.name).loaded}
          options = reflection.options

          if composite?
            where = (primary_key * ids.size).in_groups_of(primary_key.size).map do |keys|
              "(" + keys.map{|key| "t0.#{connection.quote_column_name(key)} = ?"}.join(" AND ") + ")"
            end.join(" OR ")

            conditions = [where, ids].flatten
            joins = "INNER JOIN #{connection.quote_table_name options[:join_table]} t0 ON #{full_composite_join_clause(reflection, reflection.klass.table_name, reflection.klass.primary_key, 't0', reflection.association_foreign_key)}"
            parent_primary_keys = reflection.cpk_primary_key.map{|k| "t0.#{connection.quote_column_name(k)}"}

            concat_arr = ["'['"] +
                         parent_primary_keys.zip(["', '"] * (parent_primary_keys.size - 1)).flatten.compact +
                         ["']'"]

            parent_record_id = connection.concat(*concat_arr)
          else
            conditions = "t0.#{reflection.primary_key_name} #{in_or_equals_for_ids(ids)}"
            conditions << append_conditions(reflection, preload_options)
            conditions = [conditions, ids]
            joins = "INNER JOIN #{connection.quote_table_name options[:join_table]} t0 ON #{reflection.klass.quoted_table_name}.#{reflection.klass.primary_key} = t0.#{reflection.association_foreign_key}"
            parent_record_id = reflection.primary_key_name
         end

        associated_records = reflection.klass.unscoped.where(conditions).
            includes(options[:include]).
            joins(joins).
            select("#{options[:select] || table_name+'.*'}, #{parent_record_id} as the_parent_record_id").
            order(options[:order]).to_a

          set_association_collection_records(id_to_record_map, reflection.name, associated_records, 'the_parent_record_id')
        end

        def preload_belongs_to_association(records, reflection, preload_options={})
          return if records.first.send("loaded_#{reflection.name}?")
          options = reflection.options
          
          ids = Array.new
          
          if options[:polymorphic]
            # CPK
            #polymorph_type = options[:foreign_type]
            #klasses_and_ids = {}

            # Construct a mapping from klass to a list of ids to load and a mapping of those ids back to their parent_records
            #records.each do |record|
            #  if klass = record.send(polymorph_type)
            #    klass_id = record.send(primary_key_name)
            #    if klass_id
            #      id_map = klasses_and_ids[klass] ||= {}
            #      id_list_for_klass_id = (id_map[klass_id.to_s] ||= [])
            #      id_list_for_klass_id << record
            #    end
            #  end
            #end
            #klasses_and_ids = klasses_and_ids.to_a
            raise AssociationNotSupported, "Polymorphic joins not supported for composite keys"
          else
            # I need to keep the original ids for each record (as opposed to the stringified) so
            # that they get properly converted for each db so the id_map ends up looking like:
            #
            # { '1,2' => {:id => [1,2], :records => [...records...]}}
            id_map = {}

            records.each do |record|
              keys = reflection.cpk_primary_key.map{|k| record.send(k)}
              ids << keys

              mapped_records = (id_map[keys.to_s] ||= [])
              mapped_records << record
            end

            klasses_and_ids = [[reflection.klass.name, id_map]]
          end

          klasses_and_ids.each do |klass_and_id|
            klass_name, id_map = *klass_and_id
            next if id_map.empty?
            klass = klass_name.constantize

            table_name = klass.quoted_table_name
            primary_key = [reflection.options[:primary_key] || klass.primary_key].flatten

            # CPK
            conditions = id_map.map do |key, value|
              "(" +
              primary_key.map do |key|
                "#{table_name}.#{connection.quote_column_name(key)} = ?"
              end.join(' AND ') + ")"
            end.join(' OR ')

            conditions << append_conditions(reflection, preload_options)

            conditions = [conditions] + ids.uniq.flatten

            associated_records = klass.unscoped.where(conditions).apply_finder_options(options.slice(:include, :select, :joins, :order)).to_a

            set_association_single_records(id_map, reflection.name, associated_records, primary_key)
          end
        end
        
        def find_associated_records(ids, reflection, preload_options)
          options = reflection.options
          table_name = reflection.klass.quoted_table_name

          if interface = reflection.options[:as]
            conditions = "#{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_id"} #{in_or_equals_for_ids(ids)} and #{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_type"} = '#{self.base_class.sti_name}'"
          else
            foreign_key = reflection.cpk_primary_key

            where = (foreign_key * ids.size).in_groups_of(foreign_key.size).map do |keys|
              "(" + keys.map{|key| "#{reflection.klass.quoted_table_name}.#{connection.quote_column_name(key)} = ?"}.join(" AND ") + ")"
            end.join(" OR ")

            conditions = [where, ids].flatten
          end

          conditions[0] << append_conditions(reflection, preload_options)

          find_options = {
            :select => preload_options[:select] || options[:select] || "#{table_name}.*",
            :include => preload_options[:include] || options[:include],
            # CPK
            # :conditions => [conditions, ids],
            :conditions => conditions,
            :joins => options[:joins],
            :group => preload_options[:group] || options[:group],
            :order => preload_options[:order] || options[:order]
          }

          reflection.klass.unscoped.apply_finder_options(find_options).to_a
        end

        def full_composite_join_clause(reflection, table1, full_keys1, table2, full_keys2)
          connection = reflection.active_record.connection
          full_keys1 = full_keys1.split(CompositePrimaryKeys::ID_SEP) if full_keys1.is_a?(String)
          full_keys2 = full_keys2.split(CompositePrimaryKeys::ID_SEP) if full_keys2.is_a?(String)
          where_clause = [full_keys1, full_keys2].transpose.map do |key_pair|
            quoted1 = connection.quote_table_name(table1)
            quoted2 = connection.quote_table_name(table2)
            "#{quoted1}.#{connection.quote_column_name(key_pair.first)}=#{quoted2}.#{connection.quote_column_name(key_pair.last)}"
          end.join(" AND ")
          "(#{where_clause})"
        end
      end
    end
  end
end