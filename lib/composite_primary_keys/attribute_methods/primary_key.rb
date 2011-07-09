module ActiveRecord
  module AttributeMethods
    module PrimaryKey
      # Returns this record's primary key(s) value(s) wrapped in an Array,
      # or nil if the record is not persisted?
      # If the record just has been destroyed, still return its original ids
      def to_key
        if self.composite?
          id unless id.compact.empty?
        else
          key = send(self.class.primary_key)
          [key] if key
        end
      end
    end
  end
end
