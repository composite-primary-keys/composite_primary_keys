module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute(attr_name, value)
        attr_name = attr_name.to_s
        # CPK
        # attr_name = self.class.primary_key if attr_name == 'id'
        attr_name = self.class.primary_key if (attr_name == 'id' and !self.composite?)
        @attributes_cache.delete(attr_name)
        if (column = column_for_attribute(attr_name)) && column.number?
          @attributes[attr_name] = convert_number_column_value(value)
        else
          @attributes[attr_name] = value
        end
      end
    end
  end
end
