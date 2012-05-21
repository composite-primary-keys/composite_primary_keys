require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :postgresql do
  desc 'Create the PostgreSQL test database'
  task :create_database do
    ActiveRecord::Base.clear_all_connections!
    spec = CompositePrimaryKeys::ConnectionSpec['postgresql'].dup
    database_name = spec.delete('database')
    spec['database'] = 'postgres'
    connection = ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Base.connection.create_database(database_name)
    ActiveRecord::Base.clear_all_connections!
  end

  desc 'Build the PostgreSQL test database'
  task :build_database => [:create_database] do
    path = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'postgresql.sql')
    sql = File.open(path, 'rb') do |file|
      file.read
    end

    Rake::Task['postgresql:load_connection'].invoke
    ActiveRecord::Base.connection.execute(sql)
  end

  desc 'Drop the PostgreSQL test database'
  task :drop_database => :load_connection do
    ActiveRecord::Base.clear_all_connections!
    spec = CompositePrimaryKeys::ConnectionSpec['postgresql'].dup
    database_name = spec.delete('database')
    spec['database'] = 'postgres'
    connection = ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Base.connection.drop_database(SPEC['database'])
    ActiveRecord::Base.clear_all_connections!
  end

  desc 'Rebuild the PostgreSQL test database'
  task :rebuild_database => [:drop_database, :build_database]

  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_postgresql", "connection")
  end
end