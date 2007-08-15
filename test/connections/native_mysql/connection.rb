print "Using native MySQL\n"
require 'logger'
require 'adapter_helper/mysql'

ActiveRecord::Base.logger = Logger.new("debug.log")

# Adapter config setup in locals/database_connections.rb
connection_options = AdapterHelper::MySQL.load_connection_from_env

# Setup some defaults
connection_options[:database] ||= 'composite_primary_keys_unittest'
db_name = connection_options[:database]

ActiveRecord::Base.configurations = { db_name => connection_options }
ActiveRecord::Base.establish_connection(connection_options)
