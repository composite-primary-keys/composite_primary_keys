print "Using native MySQL\n"
require 'logger'
require 'adapter_helper/mysql'

ActiveRecord::Base.logger = Logger.new("debug.log")

# ENV['cpk_adapters] should be setup in locals/database_connections.rb
adapters = YAML.load(ENV['cpk_adapters'])
connection_options = adapters["mysql"]

# Setup some defaults
connection_options[:adapter]    = 'mysql'
connection_options[:database] ||= 'composite_primary_keys_unittest'
db_name = connection_options[:database]

ActiveRecord::Base.configurations = { db_name => connection_options }
ActiveRecord::Base.establish_connection(connection_options)
