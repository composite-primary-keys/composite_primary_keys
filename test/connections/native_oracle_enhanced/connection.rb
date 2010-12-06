print "Using native Oracle Enhanced\n"

require 'adapter_helper/oracle_enhanced'
require 'active_record'

def connection_string
  "#{connection_SPEC['username']}/#{connection_SPEC['password']}@#{connection_SPEC['host']}"
end

# Adapter config setup in locals/database_connections.rb
spec = CompositePrimaryKeys::ConnectionSpec[:oracle]
ActiveRecord::Base.establish_connection(spec)

# Change default options for Oracle Enhanced adapter
ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_dates_by_column_name = true
# Change NLS_DATE_FORMAT to non-default format to verify that all tests should pass
ActiveRecord::Base.connection.execute %q{alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'}
