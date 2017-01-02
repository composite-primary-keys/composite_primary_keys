source 'https://rubygems.org'

gem 'activerecord', '~> 5.0.0'
gem 'rake'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

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
  gem 'sqlite3'
end

group :sqlserver do
  gem 'tiny_tds'
  gem 'activerecord-sqlserver-adapter', :git => 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter.git'
end