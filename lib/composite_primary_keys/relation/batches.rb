module CompositePrimaryKeys
  module ActiveRecord
    module Batches
      def find_in_batches(options = {})
        options.assert_valid_keys(:start, :batch_size)

        relation = self
        start = options[:start]
        batch_size = options[:batch_size] || 1000

        unless block_given?
          return to_enum(:find_in_batches, options) do
            total = start ? where(table[primary_key].gteq(start)).size : size
            (total - 1).div(batch_size) + 1
          end
        end

        if logger && (arel.orders.present? || arel.taken.present?)
          logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
        end

        relation = relation.reorder(batch_order).limit(batch_size)

        # CPK
        # records = start ? relation.where(table[primary_key].gteq(start)).to_a : relation.to_a
        records = if start
                    self.primary_key.reduce(relation) do |rel, key|
                      rel.where(table[key].gteq(start))
                    end
                  else
                    relation.to_a
                  end

        while records.any?
          records_size = records.size
          primary_key_offset = records.last.id
          raise "Primary key not included in the custom select clause" unless primary_key_offset

          yield records

          break if records_size < batch_size

          if primary_key_offset
            # CPK
            # Lexicographically select records
            #
            query = prefixes(primary_key.zip(primary_key_offset)).map do |kvs|
              and_clause = kvs.each_with_index.map do |(k, v), i|
                # Use > for the last key in the and clause
                # otherwise use =
                if i == kvs.length - 1
                  table[k].gt(v)
                else
                  table[k].eq(v)
                end
              end.reduce(:and)

              Arel::Nodes::Grouping.new(and_clause)
            end.reduce(:or)
          end

          records = relation.where(query)
        end
      end

      private

      # Helper method to collect prefixes of an array:
      # prefixes([:a, :b, :c]) => [[:a], [:a, :b], [:a, :b, :c]]
      #
      def prefixes(ary)
        ary.length.times.reduce([]) { |results, i| results << ary[0..i] }
      end

      def batch_order
        # CPK
        # "#{quoted_table_name}.#{quoted_primary_key} ASC"
        self.primary_key.map do |key|
          "#{quoted_table_name}.#{key} ASC"
        end.join(",")
      end
    end
  end
end
