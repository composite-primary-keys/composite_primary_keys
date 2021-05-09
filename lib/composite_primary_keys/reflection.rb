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
      def foreign_key
        # CPK
        # @foreign_key ||= -(options[:foreign_key]&.to_s || derive_foreign_key)
        @foreign_key ||= extract_keys(options[:foreign_key]) || derive_foreign_key
      end

      def association_foreign_key
        # CPK
        # @association_foreign_key ||= -(options[:association_foreign_key]&.to_s || class_name.foreign_key)
        @association_foreign_key ||= extract_keys(options[:association_foreign_key]) || class_name.foreign_key
      end

      def active_record_primary_key
        # CPK (Rails freezes the string returned in the expression that calculates PK here. But Rails uses the `-` method which is not available on Array for CPK, so we calculate it in one line and freeze it on the next)
        # @active_record_primary_key ||= -(options[:primary_key]&.to_s || primary_key(active_record))
        @active_record_primary_key ||= begin
          pk = options[:primary_key] || primary_key(active_record)
          pk.freeze
        end
      end

      private

      def extract_keys(keys)
        case keys
          when Array
            keys.map { |k| k.to_s }
          when NilClass
            nil
          else
            keys.to_s
        end
      end
    end

    class BelongsToReflection < AssociationReflection
      def association_primary_key(klass = nil)
        if primary_key = options[:primary_key]
          # CPK
          # @association_primary_key ||= -primary_key.to_s
          @association_primary_key ||= primary_key.freeze
        else
          primary_key(klass || self.klass)
        end
      end
    end

    class ThroughReflection < AbstractReflection #:nodoc:
      def association_primary_key(klass = nil)
        # Get the "actual" source reflection if the immediate source reflection has a
        # source reflection itself
        if primary_key = actual_source_reflection.options[:primary_key]
          # CPK
          # @association_primary_key ||= -primary_key.to_s
          @association_primary_key ||= primary_key.freeze
        else
          primary_key(klass || self.klass)
        end
      end
    end
  end
end
