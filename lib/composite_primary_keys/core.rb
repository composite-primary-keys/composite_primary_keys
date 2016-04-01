module ActiveRecord
  module Core
    def initialize_dup(other) # :nodoc:
      @attributes = @attributes.dup
      # CPK
      # @attributes.reset(self.class.primary_key)
      Array(self.class.primary_key).each {|key| @attributes.reset(key)}

      run_callbacks(:initialize) unless _initialize_callbacks.empty?

      @aggregation_cache = {}
      @association_cache = {}

      @new_record  = true
      @destroyed   = false

      super
    end

    module ClassMethods
      def find(*ids) # :nodoc:
        # We don't have cache keys for this stuff yet
        return super unless ids.length == 1
        return super if block_given? ||
                        primary_key.nil? ||
                        scope_attributes? ||
                        columns_hash.include?(inheritance_column) ||
                        ids.first.kind_of?(Array)
        # CPK
        return super if self.composite?

        id  = ids.first
        if ActiveRecord::Base === id
          id = id.id
          ActiveSupport::Deprecation.warn(<<-MSG.squish)
            You are passing an instance of ActiveRecord::Base to `find`.
            Please pass the id of the object by calling `.id`
          MSG
        end

        key = primary_key

        statement = cached_find_by_statement(key) { |params|
          where(key => params.bind).limit(1)
        }
        record = statement.execute([id], self, connection).first
        unless record
          raise RecordNotFound.new("Couldn't find #{name} with '#{primary_key}'=#{id}",
                                   name, primary_key, id)
        end
        record
      rescue RangeError
        raise RecordNotFound.new("Couldn't find #{name} with an out of range value for '#{primary_key}'",
                                 name, primary_key)
      end
    end
  end
end