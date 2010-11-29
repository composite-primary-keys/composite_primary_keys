require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :sqlite3 do
  desc 'Build the sqlite test databases'
  task :build_databases => :load_connection do
    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'sqlite.sql')
    dbfile = File.join(PROJECT_ROOT, connection_string)
    cmd = "mkdir -p #{File.dirname(dbfile)}"
    puts cmd
    sh %{ #{cmd} }
    cmd = "sqlite3 #{dbfile} < #{schema}"
    puts cmd
    sh %{ #{cmd} }
  end

  desc 'Drop the sqlite test databases'
  task :drop_databases => :load_connection do 
    dbfile = connection_string
    sh %{ rm -f #{dbfile} }
  end

  desc 'Rebuild the sqlite test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_sqlite", "connection")
  end
end