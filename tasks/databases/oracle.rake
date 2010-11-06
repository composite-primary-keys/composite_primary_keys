require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :oracle do
  desc 'Build the Oracle test databases'
  task :build_databases => :load_connection do
    options_str = connection_string

    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'oracle.sql')
    sh %( sqlplus #{options_str} < #{schema} )
  end

  desc 'Drop the Oracle test databases'
  task :drop_databases => :load_connection do 
    options_str = connection_string
    sh %( sqlplus #{options_str} < #{File.join(SCHEMA_PATH, 'oracle.drop.sql')} )
  end

  desc 'Rebuild the Oracle test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_oracle", "connection")
  end
end
