namespace :mysql do
  desc 'Build the MySQL test databases'
  task :build_databases => :load_connection do 
    puts File.join(SCHEMA_PATH, 'mysql.sql')
    options_str = connection_string
    # creates something like "-u#{username} -p#{password} -S#{socket}"
    sh %{ mysqladmin #{options_str} create "#{connection_spec['database']}" }
    sh %{ mysql #{options_str} "#{connection_spec['database']}" < #{File.join(SCHEMA_PATH, 'mysql.sql')} }
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases => :load_connection do 
    options_str = connection_string
    sh %{ mysqladmin #{options_str} -f drop "#{connection_spec['database']}" }
  end

  desc 'Rebuild the MySQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
  
  def connection_spec
    CompositePrimaryKeys::ConnectionSpec[:mysql]
  end

  def connection_string
    options = {}
    options['u'] = connection_spec['username']  if connection_spec['username']
    options['p'] = connection_spec['password']  if connection_spec['password']
    options['S'] = connection_spec['sock']      if connection_spec['sock']
    options.map { |key, value| "-#{key} #{value}" }.join(" ")
  end
end
