# Read the current version
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'composite_primary_keys/version'

Gem::Specification.new do |s|
  s.name         = 'composite_primary_keys'
  s.version      = CompositePrimaryKeys::VERSION::STRING
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Charlie Savage']
  s.homepage     = 'https://github.com/composite-primary-keys/composite_primary_keys'
  s.summary      = 'Composite key support for ActiveRecord'
  s.description  = 'Composite key support for ActiveRecord'
  s.date         = Time.new
  s.files        = Dir['Rakefile',
                       '*.txt',
                       '*.rdoc',
                       '*.rb',
                       'lib/**/*',
                       'local/**/*',
                       'scripts/**/*',
                       'tasks/**/*',
                       'test/**/*']
  s.require_path = 'lib'
  s.test_files   = Dir.glob('test/**')
  s.license = 'MIT'

  # Dependencies
  s.required_ruby_version = '>= 1.9.3'
  s.add_dependency('activerecord', '~>4.1.7')

  s.add_development_dependency('pg')
end
