require File.join(File.dirname(__FILE__), 'base')

module AdapterHelper
  class Postgresql < Base
    class << self
      def load_connection_from_env
        super('postgresql')
      end
    end
  end
end