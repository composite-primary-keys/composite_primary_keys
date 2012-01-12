module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute(attr_name, value)
        # CPK
        if attr_name.kind_of?(Array)
          unless value.length == attr_name.length
            raise "Number of attr_names and values do not match"
          end
          [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
          value
        else
          attr_name = attr_name.to_s
          # CPK
          # attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key
          attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key && !self.composite?
          @attributes_cache.delete(attr_name)
          column = column_for_attribute(attr_name)

          if column || @attributes.has_key?(attr_name)
            @attributes[attr_name] = type_cast_attribute_for_write(column, value)
          else
            raise ActiveModel::MissingAttributeError, "can't write unknown attribute `#{attr_name}'"
          end
        end
      end
    end
  end
end