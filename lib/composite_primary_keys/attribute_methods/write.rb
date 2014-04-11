module ActiveRecord
  module AttributeMethods
    module Write
      def write_attribute(attr_name, value)
        # CPK
        if attr_name.kind_of?(Array)
          value = [nil]*attr_name.length if value.nil?
          unless value.length == attr_name.length
            raise "Number of attr_names #{attr_name.inspect} and values #{value.inspect} do not match"
          end
          [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
          value
        else
          attr_name = attr_name.to_s
          attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key && !self.composite?
          @attributes_cache.delete(attr_name)
          column = column_for_attribute(attr_name)

          # If we're dealing with a binary column, write the data to the cache
          # so we don't attempt to typecast multiple times.
          if column && column.binary?
            @attributes_cache[attr_name] = value
          end

          if column || @attributes.has_key?(attr_name)
            @attributes[attr_name] = type_cast_attribute_for_write(column, value)
          else
            raise ActiveModel::MissingAttributeError, "can't write unknown attribute `#{attr_name}'"
          end
        end
      end
      alias_method :raw_write_attribute, :write_attribute
    end
  end
end

ActiveRecord::Base.class_eval do
  alias_method :raw_write_attribute, :write_attribute
  alias :[]= :write_attribute
  public :[]=
end
