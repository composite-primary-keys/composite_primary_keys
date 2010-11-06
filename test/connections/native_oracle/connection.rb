print "Using native Oracle\n"
require 'fileutils'
require 'logger'
require 'adapter_helper/oracle'
require 'active_record'

log_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. log]))
FileUtils.mkdir_p log_path
ActiveRecord::Base.logger = Logger.new("#{log_path}/debug.log")

def connection_string
  "#{connection_SPEC['username']}/#{connection_SPEC['password']}@#{connection_SPEC['host']}"
end

# Adapter config setup in locals/database_connections.rb
spec = CompositePrimaryKeys::ConnectionSpec[:oracle]
ActiveRecord::Base.establish_connection(spec)
