require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'composite_primary_keys', 'version')

AUTHOR = "Dr Nic Williams"
EMAIL = "drnicwilliams@gmail.com"
DESCRIPTION = "Composite key support for ActiveRecords"
GEM_NAME = "composite_primary_keys" # what ppl will type to install your gem
RUBYFORGE_PROJECT = "compositekeys"
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"

REV = nil #File.read(".svn/entries")[/committed-rev="(\d+)"/, 1] rescue nil
VERSION = ENV['VERSION'] || (CompositePrimaryKeys::VERSION::STRING + (REV ? ".#{REV}" : ""))
CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = ['--quiet', '--title', "newgem documentation",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

class Hoe
  def extra_deps 
    @extra_deps.reject { |x| Array(x).first == 'hoe' } 
  end 
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERSION) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/test*.rb"]
  p.clean_globs = CLEAN  #An array of file patterns to delete on clean.

  # == Optional
  #p.changes        - A description of the release's latest changes.
  p.extra_deps = [['activerecord', '>= 1.14.3']]  #An array of rubygem dependencies.
  #p.spec_extras    - A hash of extra values to set in the gemspec.
end

PKG_BUILD     = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_NAME      = 'composite_primary_keys'
PKG_VERSION   = CompositePrimaryKeys::VERSION::STRING + PKG_BUILD
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

RELEASE_NAME  = "REL #{PKG_VERSION}"

RUBY_FORGE_PROJECT = "compositekeys"
RUBY_FORGE_USER    = "nicwilliams"


desc "Default Task"
task :default => [ :test_sqlite ]
task :test    => [ :test_sqlite ]

# Run the unit tests

for adapter in %w( mysql sqlite oracle postgresql ) # UNTESTED - firebird sqlserver sqlserver_odbc db2 sybase openbase )
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << "test" << "test/connections/native_#{adapter}"
    t.pattern = "test/test_*.rb"
    t.verbose = true
  }
end

SCHEMA_PATH = File.join(File.dirname(__FILE__), *%w(test fixtures db_definitions))

desc 'Build the MySQL test databases'
task :build_mysql_databases do 
  puts File.join(SCHEMA_PATH, 'mysql.sql')
  %x( mysqladmin -u root create "#{PKG_NAME}_unittest" )
  %x( mysql -u root "#{PKG_NAME}_unittest" < #{File.join(SCHEMA_PATH, 'mysql.sql')} )
end

desc 'Drop the MySQL test databases'
task :drop_mysql_databases do 
  %x( mysqladmin -u root -f drop "#{PKG_NAME}_unittest" )
end

desc 'Rebuild the MySQL test databases'

task :rebuild_mysql_databases => [:drop_mysql_databases, :build_mysql_databases]

desc 'Build the sqlite test databases'
task :build_sqlite_databases do 
  file = File.join(SCHEMA_PATH, 'sqlite.sql')
  cmd = "sqlite3 test.db < #{file}"
  puts cmd
  %x( #{cmd} )
end

desc 'Drop the sqlite test databases'
task :drop_sqlite_databases do 
  %x( rm -f test.db )
end

desc 'Rebuild the sqlite test databases'
task :rebuild_sqlite_databases => [:drop_sqlite_databases, :build_sqlite_databases]

desc 'Build the PostgreSQL test databases'
task :build_postgresql_databases do 
  %x( createdb "#{PKG_NAME}_unittest" )
  %x( psql "#{PKG_NAME}_unittest" -f #{File.join(SCHEMA_PATH, 'postgresql.sql')} )
end

desc 'Drop the PostgreSQL test databases'
task :drop_postgresql_databases do 
  %x( dropdb   "#{PKG_NAME}_unittest" )
end

desc 'Rebuild the PostgreSQL test databases'
task :rebuild_postgresql_databases => [:drop_postgresql_databases, :build_postgresql_databases]
