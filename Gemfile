source 'https://rubygems.org'

gem 'activerecord', ['~>5.1.0', '>= 5.1.5']
gem 'rake'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

# group :db2 do
#   gem 'ibm_db'
# end

group :mysql do
  gem 'mysql2', '~> 0.4.0'
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

# TODO - activerecord-sqlserver-adapter requires AR 5.1.0.rc2
# group :sqlserver do
#   gem 'tiny_tds'
#   gem 'activerecord-sqlserver-adapter', :git => 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter.git'
# end
