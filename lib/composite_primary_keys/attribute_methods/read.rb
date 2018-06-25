module ActiveRecord
  module AttributeMethods
    module Read
      def read_attribute(attr_name, &block)
        name = if self.class.attribute_alias?(attr_name)
                 # CPK
                 # self.class.attribute_alias(attr_name).to_s
                 self.class.attribute_alias(attr_name)
               else
                 # CPK
                 # attr_name.to_s
                 attr_name
               end

        primary_key = self.class.primary_key
        # CPK
        # name = primary_key if name == "id".freeze && primary_key
        name = primary_key if name == "id".freeze && primary_key && !composite?
        sync_with_transaction_state if name == primary_key
        _read_attribute(name, &block)
      end

      def _read_attribute(attr_name)
        # CPK
        if attr_name.kind_of?(Array)
          attr_name.map {|name| @attributes.fetch_value(name.to_s)}
        else
          @attributes.fetch_value(attr_name.to_s) { |n| yield n if block_given? }
        end
      end
    end
  end
end
