print "Using native Oracle\n"

require 'adapter_helper/oracle'
require 'active_record'

def connection_string
  "#{connection_SPEC['username']}/#{connection_SPEC['password']}@#{connection_SPEC['host']}"
end

# Adapter config setup in locals/database_connections.rb
spec = CompositePrimaryKeys::ConnectionSpec[:oracle]
ActiveRecord::Base.establish_connection(spec)
