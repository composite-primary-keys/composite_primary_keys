require 'rake'
require 'rake/testtask'

PROJECT_ROOT = File.expand_path("..")
GEM_NAME = 'composite_primary_keys'

require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

# Load task files
Dir.glob('**/*.rake').each do |rake_file|
  load File.join(File.dirname(__FILE__), rake_file)
end

# Set up test tasks
for adapter in %w( mysql sqlite oracle oracle_enhanced postgresql ibm_db )
  Rake::TestTask.new("test_#{adapter}") do |t|
    t.libs << "test" << "test/connections/native_#{adapter}"
    t.pattern = "test/test_*.rb"
    t.verbose = true
  end
end