print "Using native Oracle Enhanced\n"
require 'fileutils'
require 'logger'
require 'adapter_helper/oracle_enhanced'

log_path = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. log]))
FileUtils.mkdir_p log_path
puts "Logging to #{log_path}/debug.log"
ActiveRecord::Base.logger = Logger.new("#{log_path}/debug.log")
ActiveRecord::Base.logger.level = Logger::DEBUG

# Adapter config setup in locals/database_connections.rb
spec = CompositePrimaryKeys::ConnectionSpec[:oracle]
ActiveRecord::Base.establish_connection(spec)

# Change default options for Oracle Enhanced adapter
ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_dates_by_column_name = true
# Change NLS_DATE_FORMAT to non-default format to verify that all tests should pass
ActiveRecord::Base.connection.execute %q{alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'}
