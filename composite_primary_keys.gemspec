# Read the current version
require File.join(File.dirname(__FILE__), 'lib', 'composite_primary_keys', 'version')

Gem::Specification.new do |s|
  s.name         = 'composite_primary_keys'
  s.version      = CompositePrimaryKeys::VERSION::STRING
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Dr Nic Williams", "Charlie Savage"]
  s.email        = ["drnicwilliams@gmail.com"]
  s.homepage     = "http://github.com/cfis/composite_primary_keys"
  s.summary      = "Composite key support for ActiveRecord"
  s.description  = "Composite key support for ActiveRecord 3"
  s.date         = Time.new
  s.files        = Dir['Rakefile',
                       '*.txt',
                       '*.rb',
                       'lib/**/*',
                       'local/**/*',
                       'scripts/**/*',
                       'tasks/**/*',
                       'test/**/*']
  s.require_path = 'lib'
  s.test_files   = Dir.glob("test/**")
  s.rubyforge_project = 'compositekeys'

  # Dependencies
  s.required_ruby_version = '>= 1.8.7'
  s.add_dependency('arel', '~> 2.1.0')
  s.add_dependency('activerecord', '= 3.1.0.rc1')
end