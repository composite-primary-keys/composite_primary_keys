module ActiveRecord
  module Associations
    class JoinDependency
      def instantiate(rows)
        primary_key = join_base.aliased_primary_key
        parents = {}

        records = rows.map { |model|
          # CPK
          #primary_id = model[primary_key]
          primary_id = if primary_key.kind_of?(Array)
            primary_key.map {|key| model[key]}
          else
            model[primary_key]
          end
          parent = parents[primary_id] ||= join_base.instantiate(model)
          construct(parent, @associations, join_associations, model)
          parent
        }.uniq

        remove_duplicate_results!(active_record, records, @associations)
        records
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