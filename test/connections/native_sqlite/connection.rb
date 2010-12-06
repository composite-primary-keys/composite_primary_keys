print "Using native Sqlite3\n"
require 'logger'
require 'active_record'
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

ActiveRecord::Base.logger = Logger.new("debug.log")

def connection_string
  SPEC['database']
end

SPEC = CompositePrimaryKeys::ConnectionSpec[:sqlite3]
ActiveRecord::Base.establish_connection(SPEC)
