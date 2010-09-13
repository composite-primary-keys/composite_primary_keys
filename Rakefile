require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

require File.join(File.dirname(__FILE__), 'lib', 'composite_primary_keys', 'version')

spec = Gem::Specification.new do |s|
  s.name        = "composite_primary_keys"
  s.version     = CompositePrimaryKeys::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dr Nic Williams", "Charlie Savage"]
  s.email       = ["drnicwilliams@gmail.com"]
  s.homepage    = "http://github.com/cfis/composite_primary_keys"
  s.summary     = "Composite key support for ActiveRecords"
  s.files        = FileList['Rakefile',
                            '*.txt',
                            '*.rb',
                            'lib/**/*',
                            'local/**/*',
                            'scripts/**/*',
                            'tasks/**/*',
                            'test/**/*'].to_a
  s.require_path = 'lib'
  s.test_files = Dir.glob("test/**")

  s.required_ruby_version = '>= 1.8.7'
  s.date = DateTime.now
  s.has_rdoc = true
  s.add_development_dependency "rspec"
end

# Rake task to build the default package
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

PROJECT_ROOT = File.expand_path(".")
