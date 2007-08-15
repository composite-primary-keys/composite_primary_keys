# UNTESTED - firebird sqlserver sqlserver_odbc db2 sybase openbase
for adapter in %w( mysql sqlite oracle postgresql ibm_db ) 
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << "test" << "test/connections/native_#{adapter}"
    t.pattern = "test/test_*.rb"
    t.verbose = true
  }
end

SCHEMA_PATH = File.join(File.dirname(__FILE__), *%w(.. test fixtures db_definitions))

namespace :mysql do
  desc 'Build the MySQL test databases'
  task :build_databases do 
    puts File.join(SCHEMA_PATH, 'mysql.sql')
    socket = '/Applications/MAMP/tmp/mysql/mysql.sock'
    user   = 'root'
    sh %{ mysqladmin -u #{user} -S #{socket} -p create "#{GEM_NAME}_unittest" }
    sh %{ mysql -u #{user} -S #{socket} -p "#{GEM_NAME}_unittest" < #{File.join(SCHEMA_PATH, 'mysql.sql')} }
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases do 
    socket = '/Applications/MAMP/tmp/mysql/mysql.sock'
    user   = 'root'
    sh %{ mysqladmin -u #{user} -S #{socket} -p -f drop "#{GEM_NAME}_unittest" }
  end

  desc 'Rebuild the MySQL test databases'

  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :sqlite do
  desc 'Build the sqlite test databases'
  task :build_databases do 
    file = File.join(SCHEMA_PATH, 'sqlite.sql')
    cmd = "sqlite3 test.db < #{file}"
    puts cmd
    sh %{ #{cmd} }
  end

  desc 'Drop the sqlite test databases'
  task :drop_databases do 
    sh %{ rm -f test.db }
  end

  desc 'Rebuild the sqlite test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases do 
    sh %{ createdb "#{GEM_NAME}_unittest" }
    sh %{ psql "#{GEM_NAME}_unittest" -f #{File.join(SCHEMA_PATH, 'postgresql.sql')} }
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases do 
    sh %{ dropdb "#{GEM_NAME}_unittest" }
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

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
