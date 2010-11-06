require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

# Set global variable so other tasks can access them
PROJECT_ROOT = File.expand_path(".")
GEM_NAME = 'composite_primary_keys'

# Read the current version
require File.join(File.dirname(__FILE__), 'lib', 'composite_primary_keys', 'version')

# Setup Gem Specs
spec = Gem::Specification.new do |s|
  s.name        = GEM_NAME
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

  s.date = Time.new
  s.has_rdoc = true

  # Dependencies
  s.required_ruby_version = '>= 1.8.7'
  s.add_dependency('active_record', '>= 3.0.1')
  s.add_development_dependency "rspec"
end

# Rake task to build the default package
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

# Load task files
Dir.glob('tasks/**/*.rake').each do |rake_file|
  load File.join(File.dirname(__FILE__), rake_file)
end

## Set up for testing
#require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')
#for adapter in %w( mysql sqlite oracle oracle_enhanced postgresql ibm_db )
#  Rake::TestTask.new("test_#{adapter}") do |t|
#    t.libs << "test" << "test/connections/native_#{adapter}"
#    t.pattern = "test/test_*.rb"
#    t.verbose = true
#  end
#end
#require 'pp'