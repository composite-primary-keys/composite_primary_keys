module CompositePrimaryKeys
  module ActiveRecord
    module Batches
      def find_in_batches(options = {})
        relation = self

        unless arel.orders.blank? && arel.taken.blank?
          ::ActiveRecord::Base.logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
        end

        if (finder_options = options.except(:start, :batch_size)).present?
          raise "You can't specify an order, it's forced to be #{batch_order}" if options[:order].present?
          raise "You can't specify a limit, it's forced to be the batch_size"  if options[:limit].present?

          relation = apply_finder_options(finder_options)
        end

        start = options.delete(:start).to_i
        batch_size = options.delete(:batch_size) || 1000

        relation = relation.reorder(batch_order).limit(batch_size)

        # CPK
        # records = relation.where(table[primary_key].gteq(start)).all
        records = self.primary_key.reduce(relation) do |rel, key|
          rel.where(table[key].gteq(start))
        end

        while records.any?
          records_size = records.size
          primary_key_offset = records.last.id

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

            records = relation.where(query)
          else
            raise "Primary key not included in the custom select clause"
          end
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
        #"#{quoted_table_name}.#{quoted_primary_key} ASC"
        self.primary_key.map do |key|
          "#{quoted_table_name}.#{key} ASC"
        end.join(",")
      end
    end
  end
end
