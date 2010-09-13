namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases do
    puts %{ createdb #{connection_string} "#{connection_spec['database']}" }
    sh %{ createdb #{connection_string} "#{connection_spec['database']}" }
    sh %{ psql #{connection_string} "#{connection_spec['database']}" -f #{File.join(SCHEMA_PATH, 'postgresql.sql')} }
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases => :load_connection do 
    sh %{ dropdb "#{connection_spec['database']}" }
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]

  def connection_spec
    CompositePrimaryKeys::ConnectionSpec[:postgresql]
  end

  def connection_string
    options = {}
    options['U'] = connection_spec['username']  if connection_spec['username']
    options['p'] = connection_spec['password']  if connection_spec['password']
    options.map { |key, value| "-#{key} #{value}" }.join(" ")
  end
end