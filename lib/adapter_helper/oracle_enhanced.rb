require File.join(File.dirname(__FILE__), 'base')

module AdapterHelper
  class OracleEnhanced < Base
    class << self
      def load_connection_from_env
        spec = super('oracle_enhanced')
        spec
      end
    end
  end
end