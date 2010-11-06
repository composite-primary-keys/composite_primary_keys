print "Using native Sqlite3\n"
require 'logger'
require 'adapter_helper/sqlite3'
require 'active_record'

ActiveRecord::Base.logger = Logger.new("debug.log")

def connection_string
  connection_SPEC['dbfile']
end

SPEC = CompositePrimaryKeys::ConnectionSpec[:sqlite3]
ActiveRecord::Base.establish_connection(SPEC)