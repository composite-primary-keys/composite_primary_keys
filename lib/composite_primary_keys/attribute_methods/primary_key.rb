module ActiveRecord
  module AttributeMethods
    module PrimaryKey
      # Returns this record's primary key value wrapped in an Array or nil if
      # the record is not persisted? or has just been destroyed.
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
