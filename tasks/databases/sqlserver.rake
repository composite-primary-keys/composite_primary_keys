require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

require 'rbconfig'
if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  sql_cmd = "osql"
else
  sql_cmd = "sqsh"
end

namespace :sqlserver do
  desc 'Build the SQL Server test database'
  task :build_database => :load_connection do
    options_str = connection_string

    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions',
                       'sqlserver.sql').gsub(File::SEPARATOR,
                                             File::ALT_SEPARATOR ||
                                             File::SEPARATOR)
    sh %( #{sql_cmd} #{options_str} -i #{schema} )
  end

  desc 'Drop the SQL Server test database'
  task :drop_database => :load_connection do
    options_str = connection_string

    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions',
                       'sqlserver.drop.sql').gsub(File::SEPARATOR,
                                                  File::ALT_SEPARATOR ||
                                                  File::SEPARATOR)
    sh %( #{sql_cmd} #{options_str} -i #{schema} )
  end

  desc 'Rebuild the SQL Server test database'
  task :rebuild_database => [:drop_database, :build_database]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_sqlserver", "connection")
  end
end
