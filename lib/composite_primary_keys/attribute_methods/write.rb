module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute(attr_name, value)
        # CPK
        #name = attr_name.to_s
        name = attr_name
        if self.class.attribute_alias?(name)
          name = self.class.attribute_alias(name)
        end

        primary_key = self.class.primary_key
        # CPK
        # name = primary_key if name == "id" && primary_key
        name = primary_key if name == "id" && primary_key && !composite?

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
