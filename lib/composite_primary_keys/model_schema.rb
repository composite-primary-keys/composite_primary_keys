module ActiveRecord
  module ModelSchema
    module ClassMethods
      def columns
        @columns ||= connection.schema_cache.columns(table_name).map do |col|
          col = col.dup
          # CPK
          #col.primary = (col.name == primary_key)
          col.primary = Array(primary_key).include?(col.name)
          col
        end
      end
    end
  end
end