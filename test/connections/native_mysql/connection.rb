print "Using native MySQL\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

db1 = 'composite_primary_keys_unittest'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :username => "root",
  :encoding => "utf8",
  :database => db1
)
