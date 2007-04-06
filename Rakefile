require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require File.join(File.dirname(__FILE__), 'lib', 'composite_primary_keys', 'version')

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

# Generate the RDoc documentation

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Composite Primary Keys -- Composite keys for Active Records/Rails"
  rdoc.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  rdoc.template = "#{ENV['template']}.rb" if ENV['template']
  rdoc.rdoc_files.include('README', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/active_record/vendor/*')
  rdoc.rdoc_files.include('dev-utils/*.rb')
}

# Enhance rdoc task to copy referenced images also
task :rdoc do
  FileUtils.mkdir_p "doc/files/examples/"
end


# Create compressed packages

dist_dirs = [ "lib", "test", "website", "scripts" ]

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = "Support for composite primary keys in ActiveRecords"
  s.description = %q{ActiveRecords only support a single primary key, preventing their use on legacy databases where tables have primary keys over 2+ columns. This solution allows an ActiveRecord to be extended to support multiple keys using the class method set_primary_keys.}

  s.files = [ "Rakefile", "install.rb", "README", "CHANGELOG" ]
  dist_dirs.each do |dir|
    s.files = s.files + Dir.glob( "#{dir}/**/*" ).delete_if { |item| item.include?( "\.svn" ) }
  end
  
  s.add_dependency('activerecord', '>= 1.14.3' + PKG_BUILD)

  s.require_path = 'lib'
  s.autorequire = 'composite_primary_keys'

  s.has_rdoc = true
  s.extra_rdoc_files = %w( README )
  s.rdoc_options.concat ['--main',  'README']
  
  s.author = "Dr Nic Williams"
  s.email = "drnicwilliams@gmail.com"
  s.homepage = "http://compositekeys.rubyforge.org"
  s.rubyforge_project = "compositekeys"
end
  
Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = false
  p.need_zip = false
end

task :lines do
  lines, codelines, total_lines, total_codelines = 0, 0, 0, 0

  for file_name in FileList["lib/composite_primary_keys/**/*.rb"]
    next if file_name =~ /vendor/
    f = File.open(file_name)

    while line = f.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
    puts "L: #{sprintf("%4d", lines)}, LOC #{sprintf("%4d", codelines)} | #{file_name}"
    
    total_lines     += lines
    total_codelines += codelines
    
    lines, codelines = 0, 0
  end

  puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
end


# Publishing ------------------------------------------------------

desc "Publish the release files to RubyForge."
task :release => [ :package ] do
  `ruby scripts/rubyforge login`

  for ext in %w( gem tgz zip )
    release_command = "ruby scripts/rubyforge add_release #{PKG_NAME} #{PKG_NAME} 'REL #{PKG_VERSION}' pkg/#{PKG_NAME}-#{PKG_VERSION}.#{ext}"
    puts release_command
    system(release_command)
  end
end