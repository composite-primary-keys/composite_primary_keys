module ActiveRecord
  module Associations
    module ThroughAssociationScope
      # CPK
      include CompositePrimaryKeys::Joins
      
      def composite_ids_hash(keys, ids)
        [keys].flatten.zip([ids].flatten).inject(Hash.new) do |hash, (key, value)|
          hash[key] = value
          hash
        end
      end
      
      def construct_quoted_owner_attributes(reflection)
        if as = reflection.options[:as]
          { "#{as}_id" => owner_quoted_id,
            "#{as}_type" => reflection.klass.quote_value(
              @owner.class.base_class.name.to_s,
              reflection.klass.columns_hash["#{as}_type"]) }
        elsif reflection.macro == :belongs_to
          # CPK
          # { reflection.klass.primary_key => @owner[reflection.primary_key_name] }
          composite_ids_hash(reflection.klass.primary_key, @owner.quoted_id)
        else
          # CPK
         #{ reflection.primary_key_name => owner_quoted_id }
          composite_ids_hash(reflection.cpk_primary_key, @owner.quoted_id)
        end
      end

      # Construct attributes for associate pointing to owner.
      def construct_owner_attributes(reflection)
        if as = reflection.options[:as]
          { "#{as}_id" => @owner.id,
            "#{as}_type" => @owner.class.base_class.name.to_s }
        else
          # CPK
          # { reflection.primary_key_name => @owner.id }
          composite_ids_hash(reflection.cpk_primary_key, @owner.id)
        end
      end

      def construct_joins(custom_joins = nil)
        polymorphic_join = nil
        if @reflection.source_reflection.macro == :belongs_to
          reflection_primary_key = @reflection.klass.primary_key
          source_primary_key     = @reflection.source_reflection.cpk_primary_key
          if @reflection.options[:source_type]
            polymorphic_join = "AND %s.%s = %s" % [
              @reflection.through_reflection.quoted_table_name, "#{@reflection.source_reflection.options[:foreign_type]}",
              @owner.class.quote_value(@reflection.options[:source_type])
            ]
          end
        else
          reflection_primary_key = @reflection.source_reflection.cpk_primary_key
          source_primary_key     = @reflection.through_reflection.klass.primary_key
          if @reflection.source_reflection.options[:as]
            polymorphic_join = "AND %s.%s = %s" % [
              @reflection.quoted_table_name, "#{@reflection.source_reflection.options[:as]}_type",
              @owner.class.quote_value(@reflection.through_reflection.klass.name)
            ]
          end
        end

        # CPK
        # "INNER JOIN %s ON %s.%s = %s.%s %s #{@reflection.options[:joins]} #{custom_joins}" % [
        #   @reflection.through_reflection.quoted_table_name,
        #   @reflection.quoted_table_name, reflection_primary_key,
        #   @reflection.through_reflection.quoted_table_name, source_primary_key,
        #   polymorphic_join
        # ]

        "INNER JOIN %s ON %s %s #{@reflection.options[:joins]} #{custom_joins}" % [
            @reflection.through_reflection.quoted_table_name,
            composite_join_clause(@reflection.klass.arel_table, reflection_primary_key,
                                  @reflection.through_reflection.klass.arel_table, source_primary_key),
            polymorphic_join
          ]
      end
    end

    module ClassMethods
      class JoinAssociation
        # CPK
        include CompositePrimaryKeys::Joins
        
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
              # [aliased_table[foreign_key].eq(parent_table[reflection.options[:primary_key] || parent.primary_key])]
              composite_join_predicates(aliased_table, foreign_key,
                                        parent_table, reflection.options[:primary_key] || parent.primary_key)
            end
          when :belongs_to
            [aliased_table[options[:primary_key] || reflection.klass.primary_key].eq(parent_table[options[:foreign_key] || reflection.cpk_primary_key])]
          end

          unless klass.descends_from_active_record?
            sti_column = aliased_table[klass.inheritance_column]
            sti_condition = sti_column.eq(klass.sti_name)
            klass.send(:subclasses).each {|subclass| sti_condition = sti_condition.or(sti_column.eq(subclass.sti_name)) }

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