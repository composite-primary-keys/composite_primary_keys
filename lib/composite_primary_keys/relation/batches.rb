module CompositePrimaryKeys
  module ActiveRecord
    module Batches
      def find_in_batches(options = {})
        relation = self

        unless arel.orders.blank? && arel.taken.blank?
          ActiveRecord::Base.logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
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
        #records = relation.where(table[primary_key].gteq(start)).all
        self.primary_key.each do |key|
          relation = relation.where(table[key].gteq(start))
        end
        records = relation.all

        while records.any?
          records_size = records.size
          primary_key_offset = records.last.id

          yield records

          break if records_size < batch_size

          if primary_key_offset
            # CPK
            #records = relation.where(table[primary_key].gt(primary_key_offset)).to_a
            self.primary_key.each do |key|
              relation = relation.where(table[key].gt(primary_key_offset))
            end
            records = relation.to_a

          else
            raise "Primary key not included in the custom select clause"
          end
        end
      end

      private

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