module ActiveRecord
  module Associations
    class JoinDependency
      def instantiate(result_set, aliases)
        primary_key = aliases.column_alias(join_root, join_root.primary_key)
        type_caster = result_set.column_type primary_key

        seen = Hash.new { |h,parent_klass|
          h[parent_klass] = Hash.new { |i,parent_id|
            i[parent_id] = Hash.new { |j,child_klass| j[child_klass] = {} }
          }
        }

        model_cache = Hash.new { |h,klass| h[klass] = {} }
        parents = model_cache[join_root]
        column_aliases = aliases.column_aliases join_root

        result_set.each { |row_hash|
          # CPK
          #primary_id = type_caster.type_cast row_hash[primary_key]
          primary_id = if row_hash[primary_key].kind_of?(Array)
            row_hash[primary_key].map {|key| type_caster.type_cast key}
          else
            type_caster.type_cast row_hash[primary_key]
          end
          parent = parents[primary_id] ||= join_root.instantiate(row_hash, column_aliases)
          construct(parent, join_root, row_hash, result_set, seen, model_cache, aliases)
        }

        parents.values
      end

      protected

      def construct_association(record, join_part, row)
        return if record.id.to_s != join_part.parent.record_id(row).to_s

        macro = join_part.reflection.macro
        if macro == :has_one
          return if record.association_cache.key?(join_part.reflection.name)
          # CPK
          # association = join_part.instantiate(row) unless row[join_part.aliased_primary_key].nil?
          association = association_for_primary_key_from_row(join_part, row)

          set_target_and_inverse(join_part, association, record)
        else
          # CPK
          # association = join_part.instantiate(row) unless row[join_part.aliased_primary_key].nil?
          association = association_for_primary_key_from_row(join_part, row)

          case macro
          when :has_many, :has_and_belongs_to_many
            other = record.association(join_part.reflection.name)
            other.loaded!
            other.target.push(association) if association
            other.set_inverse_instance(association)
          when :belongs_to
            set_target_and_inverse(join_part, association, record)
          else
            raise ConfigurationError, "unknown macro: #{join_part.reflection.macro}"
          end
        end
        association
      end

      private

      def association_for_primary_key_from_row(join_part, row)
        result = nil
        if (cpk = join_part.aliased_primary_key).is_a?(Array)
          result = join_part.instantiate(row) if cpk.detect {|pk| row[pk].nil? }.nil?
        else
          result = join_part.instantiate(row) unless row[join_part.aliased_primary_key].nil?
        end
        result
      end
    end
  end
end
