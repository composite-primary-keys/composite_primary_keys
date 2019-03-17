module ActiveRecord
  module AttributeMethods
    module Read
      def read_attribute(attr_name, &block)
        # CPK
        # name = attr_name.to_s
        name = attr_name
        if self.class.attribute_alias?(name)
          name = self.class.attribute_alias(name)
        end

        primary_key = self.class.primary_key
        # CPK
        # name = primary_key if name == "id" && primary_key
        name = primary_key if name == "id" && primary_key && !composite?
        sync_with_transaction_state if name == primary_key
        _read_attribute(name, &block)
      end

      def _read_attribute(attr_name, &block) # :nodoc
        # CPK
        if attr_name.kind_of?(Array)
          attr_name.map {|name| @attributes.fetch_value(name.to_s, &block)}
        else
          @attributes.fetch_value(attr_name.to_s, &block)
        end
      end
    end
  end
end
