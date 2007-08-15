require 'yaml'

module AdapterHelper
  class MySQL
    class << self
      def load_connection_from_env
        unless ENV['cpk_adapters']
          puts error_msg_setup_helper
          exit
        end

        all_specs = YAML.load(ENV['cpk_adapters'])
        unless spec = all_specs['mysql']
          puts error_msg_adapter_helper
          exit
        end
        spec
      end
    
      def error_msg_setup_helper
        <<-EOS
Setup Helper:
  CPK now has a place for your individual testing configuration.
  That is, instead of hardcoding it in the Rakefile and test/connections files,
  there is now a local/database_connections.rb file that is NOT in the
  repository. Your personal DB information (username, password etc) can
  be stored here without making it difficult to submit patches etc.

Installation:
  i)   cp locals/database_connections.rb.sample locals/database_connections.rb
  ii)  For MySQL connection details see "MySQL adapter Setup Helper" below.
  iii) Rerun this task
  
#{error_msg_adapter_helper}
  
Current ENV:
  #{ENV.inspect}
        EOS
      end
        
      def error_msg_adapter_helper
        <<-EOS
MySQL adapter Setup Helper:
  To run MySQL tests, you need to setup your MySQL connections.
  In your local/database_connections.rb file, within the ENV['cpk_adapter'] hash, add:
      "mysql" => { adapter settings }

  That is, it will look like:
    ENV['cpk_adapters'] = {
      "mysql" => {
        :adapter  => "mysql",
        :username => "root",
        :password => "root",
        # ...
      }
    }.to_yaml
        EOS
      end
    end
  end
end