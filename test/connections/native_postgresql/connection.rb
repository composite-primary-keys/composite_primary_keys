print "Using native Postgresql\n"
require 'logger'
require 'adapter_helper/postgresql'

ActiveRecord::Base.logger = Logger.new("debug.log")
spec = CompositePrimaryKeys::ConnectionSpec[:postgresql]
ActiveRecord::Base.establish_connection(spec)
