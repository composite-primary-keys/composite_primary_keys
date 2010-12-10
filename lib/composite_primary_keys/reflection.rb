module ActiveRecord
  module Reflection
    class AssociationReflection
      def derive_primary_key
        result = if options[:foreign_key]
          options[:foreign_key]
        elsif belongs_to?
          #CPK
          #"#{name}_id"
          class_name.foreign_key
        elsif options[:as]
          "#{options[:as]}_id"
        else
          active_record.name.foreign_key
        end
      end

      def cpk_primary_key
        # Make sure the returned key(s) are an array
        @cpk_primary_key ||= [derive_primary_key].flatten
      end

      def primary_key_name
        @primary_key_name ||= derive_primary_key_name
      end

      def derive_primary_key_name
        result = derive_primary_key

        # CPK
        if result.is_a?(Array)
          result.to_composite_keys.to_s
        else
          result
        end
      end
    end
  end
end