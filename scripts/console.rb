# FIXME:
# I haven't figured out how to setup an irb console yet.
# So, from the root, run:
# irb -f -r scripts/console

PROJECT_ROOT = '.' #File.join(File.dirname(__FILE__), '..')

adapter = 'mysql'
$:.unshift 'lib'

require "local/database_connections"
begin
  require "local/paths" 
  $:.unshift "#{ENV['EDGE_RAILS_DIR']}/activerecord/lib" if ENV['EDGE_RAILS_DIR']
  $:.unshift "#{ENV['EDGE_RAILS_DIR']}/activesupport/lib" if ENV['EDGE_RAILS_DIR']
rescue
end

require 'active_support'
require 'active_record'

require "test/connections/native_#{adapter}/connection"
require 'composite_primary_keys'

Dir[File.join(PROJECT_ROOT,'test/fixtures/*.rb')].each { |model| require model }
