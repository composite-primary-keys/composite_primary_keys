namespace :trilogy do
  task :setup do
    require 'bundler'
    Bundler.require(:default, :trilogy)
  end

  task :create_database => :setup do
    Rake::Task["mysql:create_database"].invoke
  end

  desc 'Build the MySQL test database'
  task :build_database => [:create_database] do
    Rake::Task["mysql:build_database"].invoke
  end

  desc 'Drop the MySQL test database'
  task :drop_database => :setup do
    Rake::Task["mysql:drop_database"].invoke
  end

  desc 'Rebuild the MySQL test database'
  task :rebuild_database => [:drop_database, :build_database]
end
