require 'yaml'

module CompositePrimaryKeys
  class ConnectionSpec
    def self.[](adapter)
      config[adapter.to_s]
    end

    private

    def self.config
      @config ||= begin
        path = File.join(PROJECT_ROOT, 'test', 'connections', 'databases.yml')
        YAML.load_file(path)
      end
    end
  end
end
