require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :mysql do
  desc 'Create the MySQL test databases'
  task :create_database do
    ActiveRecord::Base.clear_all_connections!
    spec = CompositePrimaryKeys::ConnectionSpec['mysql'].dup
    database_name = spec.delete('database')
    connection = ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Base.connection.create_database(database_name)
    ActiveRecord::Base.clear_all_connections!
  end

  desc 'Build the MySQL test databases'
  task :build_databases => [:create_database] do
    path = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'mysql.sql')
    sql = File.open(path, 'rb') do |file|
      file.read
    end

    Rake::Task['mysql:load_connection'].invoke
    ActiveRecord::Base.connection.execute(sql)
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases => :load_connection do
    ActiveRecord::Base.connection.drop_database(SPEC['database'])
  end

  desc 'Rebuild the MySQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
  
  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_mysql", "connection")
  end
end