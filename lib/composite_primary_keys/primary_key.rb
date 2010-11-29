module ActiveRecord
  module AttributeMethods #:nodoc:
    module PrimaryKey
      def to_key
        primary_key = self.class.primary_key
        if primary_key.is_a?(Array)
          primary_key.collect{|k| send(k)}
        else
          super
        end
      end
    end
  end
end