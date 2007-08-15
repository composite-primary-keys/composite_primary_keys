# UNTESTED - firebird sqlserver sqlserver_odbc db2 sybase openbase
for adapter in %w( mysql sqlite oracle postgresql ibm_db ) 
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << "test" << "test/connections/native_#{adapter}"
    t.pattern = "test/test_*.rb"
    t.verbose = true
  }
end

SCHEMA_PATH = File.join(File.dirname(__FILE__), *%w(.. test fixtures db_definitions))
