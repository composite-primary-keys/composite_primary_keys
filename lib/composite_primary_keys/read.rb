module ActiveRecord
  module AttributeMethods
    module Read
      def read_attribute(attr_name)
        attr_name = attr_name.to_s
        # CPK
        # attr_name = self.class.primary_key if attr_name == 'id'
        attr_name = self.class.primary_key if (attr_name == 'id' and !self.composite?)
        if !(value = @attributes[attr_name]).nil?
          if column = column_for_attribute(attr_name)
            if unserializable_attribute?(attr_name, column)
              unserialize_attribute(attr_name)
            else
              column.type_cast(value)
            end
          else
            value
          end
        else
          nil
        end
      end
    end
  end
end