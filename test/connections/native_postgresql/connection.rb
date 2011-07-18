print "Using native Postgresql\n"

def connection_string
  options = Hash.new
  options['U'] = SPEC['username']  if SPEC['username']
  options['h'] = SPEC['host']  if SPEC['host']
  options['p'] = SPEC['port']  if SPEC['port']
  options.map { |key, value| "-#{key} #{value}" }.join(" ")
end

# Adapter config setup in text/connections/databases.yml
SPEC = CompositePrimaryKeys::ConnectionSpec['postgresql']
ActiveRecord::Base.establish_connection(SPEC)