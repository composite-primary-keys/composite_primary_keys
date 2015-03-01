print "Using native SQL Server\n"

gem 'activerecord-sqlserver-adapter', '~>4.1.0'
require 'activerecord-sqlserver-adapter'

require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')

def connection_string
  "-S #{SPEC['host']} -U #{SPEC['username']} -P\"#{SPEC['password']}\""
end

# Adapter config setup in locals/database_connections.rb
SPEC = CompositePrimaryKeys::ConnectionSpec['sqlserver']
ActiveRecord::Base.establish_connection(SPEC)
