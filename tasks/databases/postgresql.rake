namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases do
    puts %{ createdb #{connection_string} "#{GEM_NAME}_unittest" }
    sh %{ createdb #{connection_string} "#{GEM_NAME}_unittest" }
    sh %{ psql #{connection_string} "#{GEM_NAME}_unittest" -f #{File.join(SCHEMA_PATH, 'postgresql.sql')} }
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases => :load_connection do 
    sh %{ dropdb "#{GEM_NAME}_unittest" }
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]

  def connection_string
    spec = CompositePrimaryKeys::ConnectionSpec[:postgresql]
    options = {}
    options['U'] = spec['username']  if spec['username']
    options['p'] = spec['password']  if spec['password']
    options.map { |key, value| "-#{key} #{value}" }.join(" ")
  end
end