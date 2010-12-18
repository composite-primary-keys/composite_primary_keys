print "Using native MySQL\n"

require 'active_record'

def connection_string
  options = {}
  options['u'] = SPEC['username']  if SPEC['username']
  options['p'] = SPEC['password']  if SPEC['password']
  options['S'] = SPEC['sock']      if SPEC['sock']
  options.map { |key, value| "-#{key} #{value}" }.join(" ")
end

  # Adapter config setup in locals/database_connections.rb
SPEC = CompositePrimaryKeys::ConnectionSpec[:mysql]
ActiveRecord::Base.establish_connection(SPEC)
