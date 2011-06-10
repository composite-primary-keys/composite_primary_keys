print "Using native Sqlite3\n"

require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

def connection_string
  SPEC['database']
end

SPEC = CompositePrimaryKeys::ConnectionSpec[:sqlite3]
ActiveRecord::Base.establish_connection(SPEC)
