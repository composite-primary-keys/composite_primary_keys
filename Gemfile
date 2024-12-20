source 'https://rubygems.org'

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

group :db2 do
  gem 'ibm_db'
end

group :mysql do
  gem 'mysql2'
end

group :oracle do
  gem 'ruby-oci8'
  gem 'ruby-plsql'
  gem 'activerecord-oracle_enhanced-adapter'
end

group :postgresql do
  gem 'pg'
end

group :sqlite do
  # Needed to match active record sqlite3 connection adapter
  gem 'sqlite3', '~> 1.4'
end

group :sqlserver do
  gem 'activerecord-sqlserver-adapter'
end

group :test do
  gem 'minitest'
end

# Load composite primary keys last since we may override code from the activerecord-sqlserver-adapter if using SqlServer.
gemspec
