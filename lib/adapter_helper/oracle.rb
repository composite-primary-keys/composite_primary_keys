require File.join(File.dirname(__FILE__), 'base')

module AdapterHelper
  class Oracle < Base
    class << self
      def load_connection_from_env
        spec = super('oci')
        spec[:username] ||= 'scott'
        spec[:password] ||= 'tiger'
        spec[:host] ||= 'xe'
        spec
      end
    end
  end
end