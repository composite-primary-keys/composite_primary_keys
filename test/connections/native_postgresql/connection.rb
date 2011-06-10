print "Using native Postgresql\n"

require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')
require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys', 'connection_adapters', 'postgresql_adapter')

def connection_string
  options = Hash.new
  options['U'] = SPEC['username']  if SPEC['username']
  options.map { |key, value| "-#{key} #{value}" }.join(" ")
end

SPEC = CompositePrimaryKeys::ConnectionSpec[:postgresql]
ActiveRecord::Base.establish_connection(SPEC)
