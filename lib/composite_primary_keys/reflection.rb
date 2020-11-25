module ActiveRecord
  module Reflection
    class AbstractReflection
      def join_scope(table, foreign_table, foreign_klass)
        predicate_builder = predicate_builder(table)
        scope_chain_items = join_scopes(table, predicate_builder)
        klass_scope       = klass_join_scope(table, predicate_builder)

        key         = join_primary_key
        foreign_key = join_foreign_key

        # CPK
        #klass_scope.where!(table[key].eq(foreign_table[foreign_key]))
        constraint = cpk_join_predicate(table, key, foreign_table, foreign_key)
        klass_scope.where!(constraint)

        if type
          klass_scope.where!(type => foreign_klass.polymorphic_name)
        end

        if klass.finder_needs_type_condition?
          klass_scope.where!(klass.send(:type_condition, table))
        end

        scope_chain_items.inject(klass_scope, &:merge!)
      end
    end

    class AssociationReflection < MacroReflection
      def active_record_primary_key
        # CPK (Rails freezes the string returned in the expression that calculates PK here. But Rails uses the `-` method which is not available on Array for CPK, so we calculate it in one line and freeze it on the next)
        # @active_record_primary_key ||= -(options[:primary_key]&.to_s || primary_key(active_record))
        pk = options[:primary_key]&.to_s || primary_key(active_record)
        @active_record_primary_key ||= pk.freeze
      end
    end
  end
end
