print "Using native Sqlite3\n"
require 'logger'
require 'adapter_helper/sqlite3'

ActiveRecord::Base.logger = Logger.new("debug.log")

# Adapter config setup in locals/database_connections.rb
spec = CompositePrimaryKeys::ConnectionSpec[:sqlite3]
ActiveRecord::Base.establish_connection(spec)