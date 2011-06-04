print "Using native Oracle Enhanced\n"

require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')

def connection_string
  "#{SPEC['username']}/#{SPEC['password']}@#{SPEC['host']}"
end

# Adapter config setup in locals/database_connections.rb
SPEC = CompositePrimaryKeys::ConnectionSpec[:oracle]
ActiveRecord::Base.establish_connection(SPEC)

# Change default options for Oracle Enhanced adapter
ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_dates_by_column_name = true
# Change NLS_DATE_FORMAT to non-default format to verify that all tests should pass
ActiveRecord::Base.connection.execute %q{alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'}
