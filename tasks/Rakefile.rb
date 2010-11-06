#require 'rake'
#require 'rake/testtask'
#
#require File.join(PROJECT_ROOT, 'test', 'connections', 'connection_spec')
#
## Set up test tasks
#for adapter in %w( mysql sqlite oracle oracle_enhanced postgresql ibm_db )
#  Rake::TestTask.new("test_#{adapter}") do |t|
#    t.libs << "test" << "test/connections/native_#{adapter}"
#    t.pattern = "test/test_*.rb"
#    t.verbose = true
#  end
#nd