module ActiveRecord
  class Base
    def self.load_cpk_adapter(adapter)
      if adapter.to_s =~ /postgresql/ || adapter.to_s =~ /postgis/
        require "composite_primary_keys/connection_adapters/postgresql_adapter.rb"
      end
      if adapter.to_s =~ /sqlserver/
        require "composite_primary_keys/connection_adapters/sqlserver_adapter.rb"
      end
    end

    def self.establish_connection(spec = nil)
      # NOTE: When passing a string `spec` such as `"development"`,
      # it needs to be casted to symbol `:development`,
      # due to the `resolver` expecting a Hash or a symbol.
      if spec.is_a?(String)
        spec.to_sym!
      end

      spec     ||= ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_sym
      resolver =   ConnectionAdapters::ConnectionSpecification::Resolver.new configurations
      spec     =   resolver.spec(spec, self == Base ? "primary" : name)
      self.connection_specification_name = spec.name

      # CPK
      load_cpk_adapter(spec.config[:adapter])

      unless respond_to?(spec.adapter_method)
        raise AdapterNotFound, "database configuration specifies nonexistent #{spec.config[:adapter]} adapter"
      end

      remove_connection
      connection_handler.establish_connection spec
    end

    class << self
      # Returns the connection currently associated with the class. This can
      # also be used to "borrow" the connection to do database work unrelated
      # to any of the specific Active Records.
      def connection
        retrieve_connection
      end

      # Returns the configuration of the associated connection as a hash:
      #
      #  ActiveRecord::Base.connection_config
      #  # => {:pool=>5, :timeout=>5000, :database=>"db/development.sqlite3", :adapter=>"sqlite3"}
      #
      # Please use only for reading.
      def connection_config
        connection_pool.spec.config
      end

      def connection_pool
        connection_handler.retrieve_connection_pool(connection_specification_name)
      end

      def retrieve_connection
        connection_handler.retrieve_connection(connection_specification_name)
      end

      # Returns true if Active Record is connected.
      def connected?
        connection_handler.connected?(connection_specification_name)
      end

      def remove_connection(id = connection_specification_name)
        connection_handler.remove_connection(id)
      end

      def clear_active_connections!
        connection_handler.clear_active_connections!
      end

      delegate :clear_reloadable_connections!, :clear_all_connections!, :to => :connection_handler
    end
  end
end
