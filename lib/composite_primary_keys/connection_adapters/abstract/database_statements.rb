module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      def join_to_delete(delete, select, key) #:nodoc:
        subselect = subquery_for(key, select)
        rewrite_ck(key)
        delete.where key.in(subselect)
      end

      private
        def rewrite_ck(key)
          if key.respond_to?(:name) && key.name.is_a?(Array)
            new_name = key.name.each_with_index.map do |field, idx|
              table_name = idx == 0 ? "" : "#{@connection.quote_table_name(key.relation.name)}."
              "#{table_name}#{@connection.quote_column_name(field)}"
            end.join(",")

            key.name = Arel::Nodes::SqlLiteral.new("#{new_name}")
        end

    end
  end
end