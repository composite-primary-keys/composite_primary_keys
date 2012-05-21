require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :sqlite3 do
  desc 'Build the sqlite test database'
  task :build_database => :load_connection do
    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'sqlite.sql')
    dbfile = File.join(PROJECT_ROOT, connection_string)
    FileUtils.mkdir_p(File.dirname(dbfile))
    cmd = "sqlite3 #{dbfile} < #{schema}"
    puts cmd
    sh %{ #{cmd} }
  end

  desc 'Drop the sqlite test database'
  task :drop_database => :load_connection do 
    dbfile = connection_string
    sh %{ rm -f #{dbfile} }
  end

  desc 'Rebuild the sqlite test database'
  task :rebuild_database => [:drop_database, :build_database]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_sqlite3", "connection")
  end
end
