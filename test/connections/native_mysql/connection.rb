print "Using native MySQL\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

db1 = 'composite_primary_keys_unittest'

connection_options = {
  :adapter  => "mysql",
  :username => "root",
  :password => "root",
  :socket   => '/Applications/MAMP/tmp/mysql/mysql.sock',
  :encoding => "utf8",
  :database => db1
}

ActiveRecord::Base.configurations = { db1 => connection_options }
ActiveRecord::Base.establish_connection(connection_options)
