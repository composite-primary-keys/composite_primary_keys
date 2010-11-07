module ActiveRecord
  module Associations
    module ClassMethods
      class JoinDependency
        class JoinBase
          def column_names_with_alias
            unless defined?(@column_names_with_alias)
              @column_names_with_alias = []
              keys = active_record.composite? ? primary_key.map(&:to_s) : [primary_key]
              (keys + (column_names - keys)).each_with_index do |column_name, i|
                @column_names_with_alias << [column_name, "#{ aliased_prefix }_r#{ i }"]
              end
            end
            @column_names_with_alias
          end
        end

        class JoinAssociation
          # Ugly to include this twice, but I couldn't figure out how to make this
          # work via a module
          def composite_join_predicates(table1, keys1, table2, keys2)
            attributes1 = [keys1].flatten.map do |key|
              table1[key]
            end

            attributes2 = [keys2].flatten.map do |key|
              table2[key]
            end

            [attributes1, attributes2].transpose.map do |attribute1, attribute2|
              attribute1.eq(attribute2)
            end
          end

          def association_join
            return @join if @join

            aliased_table = Arel::Table.new(table_name, :as => @aliased_table_name, :engine => arel_engine)
            parent_table = Arel::Table.new(parent.table_name, :as => parent.aliased_table_name, :engine => arel_engine)

            @join = case reflection.macro
            when :has_and_belongs_to_many
              join_table = Arel::Table.new(options[:join_table], :as => aliased_join_table_name, :engine => arel_engine)
              fk = options[:foreign_key] || reflection.active_record.to_s.foreign_key
              klass_fk = options[:association_foreign_key] || klass.to_s.foreign_key

              [
                join_table[fk].eq(parent_table[reflection.active_record.primary_key]),
                aliased_table[klass.primary_key].eq(join_table[klass_fk])
              ]
            when :has_many, :has_one
              if reflection.options[:through]
                join_table = Arel::Table.new(through_reflection.klass.table_name, :as => aliased_join_table_name, :engine => arel_engine)
                jt_foreign_key = jt_as_extra = jt_source_extra = jt_sti_extra = nil
                first_key = second_key = as_extra = nil

                if through_reflection.options[:as] # has_many :through against a polymorphic join
                  jt_foreign_key = through_reflection.options[:as].to_s + '_id'
                  jt_as_extra = join_table[through_reflection.options[:as].to_s + '_type'].eq(parent.active_record.base_class.name)
                else
                  jt_foreign_key = through_reflection.primary_key_name
                end

                case source_reflection.macro
                when :has_many
                  if source_reflection.options[:as]
                    first_key   = "#{source_reflection.options[:as]}_id"
                    second_key  = options[:foreign_key] || primary_key
                    as_extra    = aliased_table["#{source_reflection.options[:as]}_type"].eq(source_reflection.active_record.base_class.name)
                  else
                    first_key   = through_reflection.klass.base_class.to_s.foreign_key
                    second_key  = options[:foreign_key] || primary_key
                  end

                  unless through_reflection.klass.descends_from_active_record?
                    jt_sti_extra = join_table[through_reflection.active_record.inheritance_column].eq(through_reflection.klass.sti_name)
                  end
                when :belongs_to
                  first_key = primary_key
                  if reflection.options[:source_type]
                    second_key = source_reflection.association_foreign_key
                    jt_source_extra = join_table[reflection.source_reflection.options[:foreign_type]].eq(reflection.options[:source_type])
                  else
                    second_key = source_reflection.primary_key_name
                  end
                end

                [
                  [parent_table[parent.primary_key].eq(join_table[jt_foreign_key]), jt_as_extra, jt_source_extra, jt_sti_extra].reject{|x| x.blank? },
                  aliased_table[first_key].eq(join_table[second_key])
                ]
              elsif reflection.options[:as]
                id_rel = aliased_table["#{reflection.options[:as]}_id"].eq(parent_table[parent.primary_key])
                type_rel = aliased_table["#{reflection.options[:as]}_type"].eq(parent.active_record.base_class.name)
                [id_rel, type_rel]
              else
                foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key

                # CPK
                #[aliased_table[foreign_key].eq(parent_table[reflection.options[:primary_key] || parent.primary_key])]
                composite_join_predicates(aliased_table, foreign_key,
                                          parent_table, reflection.options[:primary_key] || parent.primary_key)
              end
            when :belongs_to
              [aliased_table[options[:primary_key] || reflection.klass.primary_key].eq(parent_table[options[:foreign_key] || reflection.primary_key_name])]
            end

            unless klass.descends_from_active_record?
              sti_column = aliased_table[klass.inheritance_column]
              sti_condition = sti_column.eq(klass.sti_name)
              klass.descendants.each {|subclass| sti_condition = sti_condition.or(sti_column.eq(subclass.sti_name)) }

              @join << sti_condition
            end

            [through_reflection, reflection].each do |ref|
              if ref && ref.options[:conditions]
                @join << interpolate_sql(sanitize_sql(ref.options[:conditions], aliased_table_name))
              end
            end

            @join
          end
        end
      end
    end
  end
end