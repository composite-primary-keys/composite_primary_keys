print "Using native Oracle\n"

require 'active_record'

def connection_string
  "#{SPEC['username']}/#{SPEC['password']}@#{SPEC['host']}"
end

# Adapter config setup in locals/database_connections.rb
SPEC = CompositePrimaryKeys::ConnectionSpec[:oracle]
ActiveRecord::Base.establish_connection(SPEC)
