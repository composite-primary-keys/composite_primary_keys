module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute(attr_name, value)
        name = if self.class.attribute_alias?(attr_name)
                 # CPK
                 #self.class.attribute_alias(attr_name).to_s
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
        _write_attribute(name, value)
      end

      def _write_attribute(attr_name, value) # :nodoc:
        # CPK
        if attr_name.kind_of?(Array)
          attr_name.each_with_index do |attr_child_name, i|
            child_value = value ? value[i] : value
            @attributes.write_from_user(attr_child_name.to_s, child_value)
          end
        else
          @attributes.write_from_user(attr_name.to_s, value)
        end

        value
      end
    end
  end
end
