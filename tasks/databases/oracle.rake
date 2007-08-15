namespace :oracle do
  desc 'Build the Oracle test databases'
  task :build_databases do 
    puts File.join(SCHEMA_PATH, 'oracle.sql')
    sh %( sqlplus holstdl/holstdl@test < #{File.join(SCHEMA_PATH, 'oracle.sql')} )
  end

  desc 'Drop the Oracle test databases'
  task :drop_databases do 
    sh %( sqlplus holstdl/holstdl@test < #{File.join(SCHEMA_PATH, 'oracle.drop.sql')} )
  end

  desc 'Rebuild the Oracle test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end
