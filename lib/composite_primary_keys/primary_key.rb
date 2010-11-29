module ActiveRecord
  module AttributeMethods #:nodoc:
    module PrimaryKey
      def to_key
        # CPK
        #key = send(self.class.primary_key)
        #[key] if key

        primary_key = self.class.primary_key
        if primary_key.is_a?(Array)
          primary_key.collect{|k| send(k)}
        else
          key = send(primary_key)
          [key] if key
        end
      end
    end
  end
end