require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :mysql do
  desc 'Build the MySQL test databases'
  task :build_databases => :load_connection do 
    options_str = connection_string
    # creates something like "-u#{username} -p#{password} -S#{socket}"
    sh %{ mysqladmin #{options_str} create "#{SPEC['database']}" }

    schema = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'mysql.sql')
    sh %{ mysql #{options_str} "#{SPEC['database']}" < #{schema} }
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases => :load_connection do 
    options_str = connection_string
    sh %{ mysqladmin #{options_str} -f drop "#{SPEC['database']}" }
  end

  desc 'Rebuild the MySQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
  
  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_mysql", "connection")
  end
end