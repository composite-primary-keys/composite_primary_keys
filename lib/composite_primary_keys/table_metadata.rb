# frozen_string_literal: true

module ActiveRecord
  class TableMetadata # :nodoc:
    def associated_with?(table_name)
      klass&._reflect_on_association(table_name) || klass&._reflect_on_association(table_name.to_s.singularize)
    end
  end
end
