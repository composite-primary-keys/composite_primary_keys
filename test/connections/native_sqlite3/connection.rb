print "Using native Sqlite3\n"

def connection_string
  SPEC['database']
end

# Adapter config setup in text/connections/databases.yml
SPEC = CompositePrimaryKeys::ConnectionSpec['sqlite3']
ActiveRecord::Base.establish_connection(SPEC)
