require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :oracle do
  desc 'Build the Oracle test database'
  task :build_database => :load_connection do
    options_str = connection_string

    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'oracle.sql')
    sh %( sqlplus #{options_str} < #{schema} )
  end

  desc 'Drop the Oracle test database'
  task :drop_database => :load_connection do 
    options_str = connection_string
    sh %( sqlplus #{options_str} < #{File.join(SCHEMA_PATH, 'oracle.drop.sql')} )
  end

  desc 'Rebuild the Oracle test database'
  task :rebuild_database => [:drop_database, :build_database]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_oracle", "connection")
  end
end
