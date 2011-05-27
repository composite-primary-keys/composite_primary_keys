module ActiveRecord
  module Associations
    class JoinDependency
      class JoinPart
        def aliased_primary_key
          # CPK
          # "#{aliased_prefix}_r0"

          active_record.composite? ?
            primary_key.inject([]) {|aliased_keys, key| aliased_keys << "#{ aliased_prefix }_r#{aliased_keys.length}"} :
            "#{ aliased_prefix }_r0"
        end

        def record_id(row)
          # CPK
          # row[aliased_primary_key]
          active_record.composite? ?
            aliased_primary_key.map {|key| row[key]}.to_composite_keys :
            row[aliased_primary_key]
        end

        def column_names_with_alias
          unless @column_names_with_alias
            @column_names_with_alias = []

            # CPK
            #([primary_key] + (column_names - [primary_key])).each_with_index do |column_name, i|
            keys = active_record.composite? ? primary_key.map(&:to_s) : [primary_key]

            (keys + (column_names - keys)).each_with_index do |column_name, i|
              @column_names_with_alias << [column_name, "#{aliased_prefix}_r#{i}"]
            end
          end
          @column_names_with_alias
        end
      end
    end
  end
end