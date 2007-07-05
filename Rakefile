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
config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
RUBYFORGE_USERNAME = config["username"]
RUBYFORGE_PROJECT = "compositekeys"
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"

REV = nil #File.read(".svn/entries")[/committed-rev="(\d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (CompositePrimaryKeys::VERSION::STRING + (REV ? ".#{REV}" : ""))
CLEAN.include ['**/.*.sw?', '*.gem', '.config','debug.log','*.db','logfile','.DS_Store', '.project']
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
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/test*.rb"]
  p.clean_globs |= CLEAN  #An array of file patterns to delete on clean.

  # == Optional
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.extra_deps = [['activerecord', '>= 1.14.3']]  #An array of rubygem dependencies.
  #p.spec_extras    - A hash of extra values to set in the gemspec.
end

CHANGES = hoe.paragraphs_of('History.txt', 0..1).join("\n\n")
PATH    = RUBYFORGE_PROJECT
hoe.remote_rdoc_dir = File.join(PATH.gsub(/^#{RUBYFORGE_PROJECT}\/?/,''), 'rdoc')


# UNTESTED - firebird sqlserver sqlserver_odbc db2 sybase openbase
for adapter in %w( mysql sqlite oracle postgresql ibm_db ) 
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << "test" << "test/connections/native_#{adapter}"
    t.pattern = "test/test_*.rb"
    t.verbose = true
  }
  namespace adapter do
    task :test => "test_#{adapter}"
  end
end

SCHEMA_PATH = File.join(File.dirname(__FILE__), *%w(test fixtures db_definitions))

namespace :mysql do
  desc 'Build the MySQL test databases'
  task :build_databases do 
    puts File.join(SCHEMA_PATH, 'mysql.sql')
    socket = '/Applications/MAMP/tmp/mysql/mysql.sock'
    user   = 'root'
    sh %{ mysqladmin -u #{user} -S #{socket} -p create "#{GEM_NAME}_unittest" }
    sh %{ mysql -u #{user} -S #{socket} -p "#{GEM_NAME}_unittest" < #{File.join(SCHEMA_PATH, 'mysql.sql')} }
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases do 
    socket = '/Applications/MAMP/tmp/mysql/mysql.sock'
    user   = 'root'
    sh %{ mysqladmin -u #{user} -S #{socket} -p -f drop "#{GEM_NAME}_unittest" }
  end

  desc 'Rebuild the MySQL test databases'

  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :sqlite do
  desc 'Build the sqlite test databases'
  task :build_databases do 
    file = File.join(SCHEMA_PATH, 'sqlite.sql')
    cmd = "sqlite3 test.db < #{file}"
    puts cmd
    sh %{ #{cmd} }
  end

  desc 'Drop the sqlite test databases'
  task :drop_databases do 
    sh %{ rm -f test.db }
  end

  desc 'Rebuild the sqlite test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases do 
    sh %{ createdb "#{GEM_NAME}_unittest" }
    sh %{ psql "#{GEM_NAME}_unittest" -f #{File.join(SCHEMA_PATH, 'postgresql.sql')} }
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases do 
    sh %{ dropdb "#{GEM_NAME}_unittest" }
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :oracle do
  desc 'Build the Oracle test databases'
  task :build_databases do 
    puts File.join(SCHEMA_PATH, 'oracle.sql')
    sh %( sqlplus holstdl/holstdl@test < #{File.join(SCHEMA_PATH, 'oracle.sql')} )
  end

  desc 'Drop the Oracle test databases'
  task :drop_databases do 
    sh %( sqlplus holstdl/holstdl@test < #{File.join(SCHEMA_PATH, 'oracle.drop.sql')} )
  end

  desc 'Rebuild the Oracle test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :idm_db do
  desc 'Create the db2 test tables'
  task :create_databases do
    sh %( db2 connect to ocdpdev user db2inst1 using password)
    sh %( db2 -tvf #{File.join(SCHEMA_PATH, 'db2-create-tables.sql')} )
  end
  
  desc 'Drop the db2 test tables'
  task :drop_databases do
    sh %( db2 connect to ocdpdev user db2inst1 using password)
    sh %( db2 -tvf #{File.join(SCHEMA_PATH, 'db2-drop-tables.sql')} )
  end
  
  desc 'Rebuild the db2 test databases'
  task :rebuild_databases => [:drop_databases, :create_databases]
end

desc 'Generate website files'
task :website_generate do
  sh %{ ruby scripts/txt2html website/index.txt > website/index.html }
  sh %{ ruby scripts/txt2js website/version.txt > website/version.js }
  sh %{ ruby scripts/txt2js website/version-raw.txt > website/version-raw.js }
end

desc 'Upload website files to rubyforge'
task :website_upload do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/"
  local_dir = 'website'
  sh %{rsync -aCv #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload, :publish_docs]

desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release] do
  puts "Remember to create SVN tag:"
  puts "svn copy svn+ssh://#{RUBYFORGE_USERNAME}@rubyforge.org/var/svn/#{PATH}/trunk " +
    "svn+ssh://#{RUBYFORGE_USERNAME}@rubyforge.org/var/svn/#{PATH}/tags/REL-#{VERS} "
  puts "Suggested comment:"
  puts "Tagging release #{CHANGES}"
end

desc 'Runs tasks website_generate and install_gem as a local deployment of the gem'
task :local_deploy => [:website_generate, :install_gem]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end
