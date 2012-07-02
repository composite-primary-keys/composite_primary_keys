print "Using native SQL Server\n"

require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')

def connection_string
  "-S #{SPEC['host']} -U #{SPEC['username']} -P\"#{SPEC['password']}\""
end

# Adapter config setup in locals/database_connections.rb
SPEC = CompositePrimaryKeys::ConnectionSpec['sqlserver']
ActiveRecord::Base.establish_connection(SPEC)
