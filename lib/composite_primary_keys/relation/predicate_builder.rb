module ActiveRecord
  class PredicateBuilder
    silence_warnings do
      def expand(column, value)
        # Find the foreign key when using queries such as:
        # Post.where(author: author)
        #
        # For polymorphic relationships, find the foreign key and type:
        # PriceEstimate.where(estimate_of: treasure)

        # CPK
        if Base === Array(value).first && Array(value).first.composite? && reflection = table.associated_with?(column)
          columns = reflection.foreign_key
          values = Array(value).map{|v| columns.map{|c| v.public_send(c) }}
          cpk_predicate_builder = Class.new.extend(CompositePrimaryKeys::Predicates)
          predicate = cpk_predicate_builder.cpk_in_predicate(table.send(:arel_table), columns, values)
          return predicate
        else
          # Original code
          value = AssociationQueryHandler.value_for(table, column, value) if table.associated_with?(column)
          build(table.arel_attribute(column), value)
        end
      end
    end
  end
end