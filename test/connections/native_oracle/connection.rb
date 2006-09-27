print "Using Oracle\n"
require_dependency 'fixtures/course'
require 'logger'

ActiveRecord::Base.logger = Logger.new STDOUT
ActiveRecord::Base.logger.level = Logger::WARN

# Set these to your database connection strings
db = ENV['ARUNIT_DB'] || 'ruby_ut'

ActiveRecord::Base.establish_connection(
  :adapter  => 'oracle',
  :username => 'ruby_ut',
  :password => 'ruby_ut1',
  :database => db
)

Course.establish_connection(
  :adapter  => 'oracle',
  :username => 'ruby_ut',
  :password => 'ruby_ut1',
  :database => db
)
