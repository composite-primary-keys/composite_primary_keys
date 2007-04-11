print "Using native Oracle\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

db1 = 'composite_primary_keys_unittest'

connection_options = {
  :adapter  => 'oci',
  :username => 'holstdl',
  :password => 'holstdl',
  :host     => 'test'
}

ActiveRecord::Base.configurations = { db1 => connection_options }
ActiveRecord::Base.establish_connection(connection_options)
