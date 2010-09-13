namespace :sqlite3 do
  desc 'Build the sqlite test databases'
  task :build_databases do 
    file = File.join(SCHEMA_PATH, 'sqlite.sql')
    dbfile = File.join(PROJECT_ROOT, connection_string)
    cmd = "mkdir -p #{File.dirname(dbfile)}"
    puts cmd
    sh %{ #{cmd} }
    cmd = "sqlite3 #{dbfile} < #{file}"
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

  def connection_spec
    CompositePrimaryKeys::ConnectionSpec[:sqlite3]
  end

  def connection_string
    connection_spec['dbfile']
  end
end
