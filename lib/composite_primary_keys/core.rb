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

    # module ClassMethods
#       def find(*ids) # :nodoc:
#         # We don't have cache keys for this stuff yet
#         return super unless ids.length == 1
#         # Allow symbols to super to maintain compatibility for deprecated finders until Rails 5
#         return super if ids.first.kind_of?(Symbol)
#         return super if block_given? ||
#           primary_key.nil? ||
#           default_scopes.any? ||
#           current_scope ||
#           columns_hash.include?(inheritance_column) ||
#           ids.first.kind_of?(Array)
#
#         # CPK
#         return super if self.composite?
#
#         id  = ids.first
#         if ActiveRecord::Base === id
#           id = id.id
#           ActiveSupport::Deprecation.warn(<<-MSG.squish)
#             You are passing an instance of ActiveRecord::Base to `find`.
#             Please pass the id of the object by calling `.id`
#           MSG
#         end
#         key = primary_key
#
#         s = find_by_statement_cache[key] || find_by_statement_cache.synchronize {
#           find_by_statement_cache[key] ||= StatementCache.create(connection) { |params|
#             where(key => params.bind).limit(1)
#           }
#         }
#         record = s.execute([id], self, connection).first
#         unless record
#           raise RecordNotFound, "Couldn't find #{name} with '#{primary_key}'=#{id}"
#         end
#         record
#       rescue RangeError
#         raise RecordNotFound, "Couldn't find #{name} with an out of range value for '#{primary_key}'"
#       end
#     end
  end
end