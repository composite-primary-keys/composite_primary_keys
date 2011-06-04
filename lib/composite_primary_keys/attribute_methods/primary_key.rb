module CompositePrimaryKeys
  module ActiveRecord
    module AttributeMethods
      module PrimaryKey
        def to_key
          # CPK
          #key = send(self.class.primary_key)
          #[key] if key

          self.class.primary_key.map do |key|
            send(key)
          end
        end
      end
    end
  end
end