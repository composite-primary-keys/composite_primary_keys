module CompositePrimaryKeys
  module ActiveRecord
    module Associations
      def self.append_features(base)
        super
        base.send(:extend, ClassMethods)
      end
      
      # Composite key versions of Association functions
      module ClassMethods
        
        def construct_counter_sql_with_included_associations(options, join_dependency)
          scope = scope(:find)
          sql = "SELECT COUNT(DISTINCT #{quoted_table_columns(primary_key)})"
          
          # A (slower) workaround if we're using a backend, like sqlite, that doesn't support COUNT DISTINCT.
          if !self.connection.supports_count_distinct?
            sql = "SELECT COUNT(*) FROM (SELECT DISTINCT #{quoted_table_columns(primary_key)}"
          end
          
          sql << " FROM #{table_name} "
          sql << join_dependency.join_associations.collect{|join| join.association_join }.join
          
          add_joins!(sql, options, scope)
          add_conditions!(sql, options[:conditions], scope)
          add_limited_ids_condition!(sql, options, join_dependency) if !using_limitable_reflections?(join_dependency.reflections) && ((scope && scope[:limit]) || options[:limit])

          add_limit!(sql, options, scope) if using_limitable_reflections?(join_dependency.reflections)

          if !self.connection.supports_count_distinct?
            sql << ")"
          end

          return sanitize_sql(sql)          
        end

        def construct_finder_sql_with_included_associations(options, join_dependency)
          scope = scope(:find)
          sql = "SELECT #{column_aliases(join_dependency)} FROM #{(scope && scope[:from]) || options[:from] || table_name} "
          sql << join_dependency.join_associations.collect{|join| join.association_join }.join
 
          add_joins!(sql, options, scope)
          add_conditions!(sql, options[:conditions], scope)
          add_limited_ids_condition!(sql, options, join_dependency) if !using_limitable_reflections?(join_dependency.reflections) && options[:limit]

          sql << "ORDER BY #{options[:order]} " if options[:order]
 
          add_limit!(sql, options, scope) if using_limitable_reflections?(join_dependency.reflections)
 
          return sanitize_sql(sql)
        end
        
        def table_columns(columns)
          columns.collect {|column| "#{self.table_name}.#{column}"}
        end
        
        def quoted_table_columns(columns)
          table_columns(columns).join(ID_SEP)
        end
      end
      
    end
  end
end

module ActiveRecord::Associations::ClassMethods
  class JoinDependency
    class JoinAssociation < JoinBase
      alias single_association_join association_join
      def association_join
        reflection.active_record.composite? ?
          composite_association_join :
          single_association_join
      end
      
      def composite_association_join
        join = case reflection.macro
          when :has_and_belongs_to_many
            " LEFT OUTER JOIN %s ON (%s) = (%s) " % [
               table_alias_for(options[:join_table], aliased_join_table_name),
               full_keys(aliased_join_table_name, options[:foreign_key] || reflection.active_record.to_s.classify.foreign_key),
               full_keys(reflection.active_record.table_name, reflection.active_record.primary_key)] +
            " LEFT OUTER JOIN %s ON (%s) = (%s) " % [
               table_name_and_alias, 
               full_keys(aliased_table_name, klass.primary_key),
               full_keys(aliased_join_table_name, options[:association_foreign_key] || klass.table_name.classify.foreign_key)
               ]
          when :has_many, :has_one
            case
              when reflection.macro == :has_many && reflection.options[:through]
                through_conditions = through_reflection.options[:conditions] ? "AND #{interpolate_sql(sanitize_sql(through_reflection.options[:conditions]))}" : ''
                if through_reflection.options[:as] # has_many :through against a polymorphic join
                  raise AssociationNotSupported, "Polymorphic joins not supported for composite keys"
                else
                  if source_reflection.macro == :has_many && source_reflection.options[:as]
                    raise AssociationNotSupported, "Polymorphic joins not supported for composite keys"
                  else
                    case source_reflection.macro
                      when :belongs_to
                        first_key  = primary_key
                        second_key = options[:foreign_key] || klass.to_s.classify.foreign_key
                      when :has_many
                        first_key  = through_reflection.klass.to_s.classify.foreign_key
                        second_key = options[:foreign_key] || primary_key
                    end
                    
                    " LEFT OUTER JOIN %s ON (%s) = (%s) "  % [
                      table_alias_for(through_reflection.klass.table_name, aliased_join_table_name), 
                      full_keys(aliased_join_table_name, through_reflection.primary_key_name),
                      full_keys(parent.aliased_table_name, parent.primary_key)] +
                    " LEFT OUTER JOIN %s ON (%s) = (%s) " % [
                      table_name_and_alias,
                      full_keys(aliased_table_name, first_key), 
                      full_keys(aliased_join_table_name, second_key)
                    ]
                  end
                end
              
              when reflection.macro == :has_many && reflection.options[:as]
                raise AssociationNotSupported, "Polymorphic joins not supported for composite keys"
              when reflection.macro == :has_one && reflection.options[:as]
                raise AssociationNotSupported, "Polymorphic joins not supported for composite keys"
              else
                foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
                " LEFT OUTER JOIN %s ON (%s) = (%s) " % [
                  table_name_and_alias,
                  full_keys(aliased_table_name, foreign_key),
                  full_keys(parent.aliased_table_name, parent.primary_key)
                ]
            end
          when :belongs_to
            " LEFT OUTER JOIN %s ON (%s) = (%s) " % [
               table_name_and_alias, 
               full_keys(aliased_table_name, reflection.klass.primary_key),
               full_keys(parent.aliased_table_name, options[:foreign_key] || klass.to_s.foreign_key)
              ]
          else
            ""
        end || ''
        join << %(AND %s.%s = %s ) % [
          aliased_table_name, 
          reflection.active_record.connection.quote_column_name(reflection.active_record.inheritance_column), 
          klass.quote(klass.name)] unless klass.descends_from_active_record?
        join << "AND #{interpolate_sql(sanitize_sql(reflection.options[:conditions]))} " if reflection.options[:conditions]
        join
      end
      
      def full_keys(table_name, keys)
        keys.collect {|key| "#{table_name}.#{key}"}.join(CompositePrimaryKeys::ID_SEP)
      end
    end
  end
end