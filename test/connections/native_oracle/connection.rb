print "Using native Oracle\n"

require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')

def connection_string
  "#{SPEC['username']}/#{SPEC['password']}@//#{SPEC['host']}:#{SPEC['port']}/#{SPEC['database']}"
end

# Adapter config setup in locals/database_connections.rb
SPEC = CompositePrimaryKeys::ConnectionSpec['oracle']
ActiveRecord::Base.establish_connection(SPEC)
