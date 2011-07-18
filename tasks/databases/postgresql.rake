require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases => :load_connection do
    sh %{ createdb #{connection_string} "#{SPEC['database']}" }

    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'postgresql.sql')
    sh %{ psql #{connection_string} "#{SPEC['database']}" -f #{schema} }
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases => :load_connection do 
    sh %{ dropdb #{connection_string} "#{SPEC['database']}" }
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_postgresql", "connection")
  end
end