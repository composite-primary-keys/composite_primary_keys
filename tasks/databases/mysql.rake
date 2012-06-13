require File.join(PROJECT_ROOT, 'lib', 'composite_primary_keys')
require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

namespace :mysql do
  desc 'Create the MySQL test database'
  task :create_database do
    ActiveRecord::Base.clear_all_connections!
    spec = CompositePrimaryKeys::ConnectionSpec['mysql'].dup
    database_name = spec.delete('database')
    connection = ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Base.connection.create_database(database_name)
    ActiveRecord::Base.clear_all_connections!
  end

  desc 'Build the MySQL test database'
  task :build_database => [:create_database] do
    path = File.join(PROJECT_ROOT, 'test', 'fixtures', 'db_definitions', 'mysql.sql')
    sql = File.open(path, 'rb') do |file|
      file.read
    end

    Rake::Task['mysql:load_connection'].reenable
    Rake::Task['mysql:load_connection'].invoke
    #puts %(ActiveRecord::Base.connection.instance_variable_get(:@config)=#{(ActiveRecord::Base.connection.instance_variable_get(:@config)).inspect})
    sql.split(";").each do |statement|
      ActiveRecord::Base.connection.execute(statement) unless statement.strip.length == 0
    end
  end

  desc 'Drop the MySQL test database'
  task :drop_database => :load_connection do
    ActiveRecord::Base.connection.drop_database(SPEC['database'])
  end

  desc 'Rebuild the MySQL test database'
  task :rebuild_database => [:drop_database, :build_database]
  
  task :load_connection do
    require File.join(PROJECT_ROOT, "test", "connections", "native_mysql", "connection")
    establish_connection
  end
end
