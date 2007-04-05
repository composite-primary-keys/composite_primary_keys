print "Using native Sqlite3\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :dbfile   => "test.db"
)

