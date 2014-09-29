module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute_with_type_cast(attr_name, value, should_type_cast)
        if attr_name.kind_of?(Array)
          value = [nil]*attr_name.length if value.nil?
          unless value.length == attr_name.length
            raise "Number of attr_names #{attr_name.inspect} and values #{value.inspect} do not match"
          end
          [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
          value
        else
          attr_name = attr_name.to_s
          # CPK
          # attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key
          attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key && !self.composite?

          if should_type_cast
            @attributes.write_from_user(attr_name, value)
          else
            @attributes.write_from_database(attr_name, value)
          end

          value
        end
      end
    end
  end
end
