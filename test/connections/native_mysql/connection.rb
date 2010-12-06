print "Using native MySQL\n"

require 'adapter_helper/mysql'
require 'active_record'

def connection_string
  options = {}
  options['u'] = SPEC['username']  if SPEC['username']
  options['p'] = SPEC['password']  if SPEC['password']
  options['S'] = SPEC['sock']      if SPEC['sock']
  options.map { |key, value| "-#{key} #{value}" }.join(" ")
end

  # Adapter config setup in locals/database_connections.rb
connection_options = AdapterHelper::MySQL.load_connection_from_env
ActiveRecord::Base.establish_connection(connection_options)
