print "Using native Postgresql\n"

require 'logger'
require 'active_record'
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')
require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys', 'connection_adapters', 'postgresql_adapter')

def connection_string
  options = {}
  options['U'] = SPEC['username']  if SPEC['username']
  options['p'] = SPEC['password']  if SPEC['password']
  options.map { |key, value| "-#{key} #{value}" }.join(" ")
end

ActiveRecord::Base.logger = Logger.new("debug.log")
SPEC = CompositePrimaryKeys::ConnectionSpec[:postgresql]
ActiveRecord::Base.establish_connection(SPEC)
