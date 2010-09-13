require 'rake'
require 'rake/testtask'

PROJECT_ROOT = File.expand_path("..")
GEM_NAME = 'composite_primary_keys'

require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')

# Load task files
Dir.glob('**/*.rake').each do |rake_file|
  load File.join(File.dirname(__FILE__), rake_file)
end