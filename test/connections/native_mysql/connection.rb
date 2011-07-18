print "Using native MySQL\n"

def connection_string
  options = {}
  options['u'] = SPEC['username']  if SPEC['username']
  options['p'] = SPEC['password']  if SPEC['password']
  options['S'] = SPEC['sock']      if SPEC['sock']
  options.map { |key, value| "-#{key}#{value}" }.join(" ")
end

# Adapter config setup in text/connections/databases.yml
SPEC = CompositePrimaryKeys::ConnectionSpec['mysql']
ActiveRecord::Base.establish_connection(SPEC)
