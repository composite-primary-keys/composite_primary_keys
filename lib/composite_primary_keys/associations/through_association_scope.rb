#module ActiveRecord
#  module Associations
#    module ThroughAssociationScope
#      def composite_join_clause(table1, keys1, table2, keys2)
#        predicates = composite_join_predicates(table1, keys1, table2, keys2)
#
#        join_clause = predicates.map do |predicate|
#          predicate.to_sql
#        end.join(" AND ")
#
#        "(#{join_clause})"
#      end
#
#      def composite_join_predicates(table1, keys1, table2, keys2)
#        attributes1 = [keys1].flatten.map do |key|
#          table1[key]
#        end
#
#        attributes2 = [keys2].flatten.map do |key|
#          table2[key]
#        end
#
#        [attributes1, attributes2].transpose.map do |attribute1, attribute2|
#          attribute1.eq(attribute2)
#        end
#      end
#
#      def composite_ids_hash(keys, ids)
#        [keys].flatten.zip([ids].flatten).inject(Hash.new) do |hash, (key, value)|
#          hash[key] = value
#          hash
#        end
#      end
#
#      def construct_quoted_owner_attributes(reflection)
#        if as = reflection.options[:as]
#          { "#{as}_id" => owner_quoted_id,
#            "#{as}_type" => reflection.klass.quote_value(
#              @owner.class.base_class.name.to_s,
#              reflection.klass.columns_hash["#{as}_type"]) }
#        elsif reflection.macro == :belongs_to
#          # CPK
#          # { reflection.klass.primary_key => @owner[reflection.primary_key_name] }
#          composite_ids_hash(reflection.klass.primary_key, @owner.quoted_id)
#        else
#          # CPK
#         #{ reflection.primary_key_name => owner_quoted_id }
#          composite_ids_hash(reflection.cpk_primary_key, @owner.quoted_id)
#        end
#      end
#
#      # Construct attributes for associate pointing to owner.
#      def construct_owner_attributes(reflection)
#        if as = reflection.options[:as]
#          { "#{as}_id" => @owner.id,
#            "#{as}_type" => @owner.class.base_class.name.to_s }
#        else
#          # CPK
#          # { reflection.primary_key_name => @owner.id }
#          composite_ids_hash(reflection.cpk_primary_key, @owner.id)
#        end
#      end
#
#      def construct_joins(custom_joins = nil)
#        polymorphic_join = nil
#        if @reflection.source_reflection.macro == :belongs_to
#          reflection_primary_key = @reflection.klass.primary_key
#          source_primary_key     = @reflection.source_reflection.cpk_primary_key
#          if @reflection.options[:source_type]
#            polymorphic_join = "AND %s.%s = %s" % [
#              @reflection.through_reflection.quoted_table_name, "#{@reflection.source_reflection.options[:foreign_type]}",
#              @owner.class.quote_value(@reflection.options[:source_type])
#            ]
#          end
#        else
#          reflection_primary_key = @reflection.source_reflection.cpk_primary_key
#          source_primary_key     = @reflection.through_reflection.klass.primary_key
#          if @reflection.source_reflection.options[:as]
#            polymorphic_join = "AND %s.%s = %s" % [
#              @reflection.quoted_table_name, "#{@reflection.source_reflection.options[:as]}_type",
#              @owner.class.quote_value(@reflection.through_reflection.klass.name)
#            ]
#          end
#        end
#
#        # CPK
#        # "INNER JOIN %s ON %s.%s = %s.%s %s #{@reflection.options[:joins]} #{custom_joins}" % [
#        #   @reflection.through_reflection.quoted_table_name,
#        #   @reflection.quoted_table_name, reflection_primary_key,
#        #   @reflection.through_reflection.quoted_table_name, source_primary_key,
#        #   polymorphic_join
#        # ]
#
#        "INNER JOIN %s ON %s %s #{@reflection.options[:joins]} #{custom_joins}" % [
#            @reflection.through_reflection.quoted_table_name,
#            composite_join_clause(@reflection.klass.arel_table, reflection_primary_key,
#                                  @reflection.through_reflection.klass.arel_table, source_primary_key),
#            polymorphic_join
#          ]
#      end
#    end
#  end
#end