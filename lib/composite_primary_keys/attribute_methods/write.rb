module CompositePrimaryKeys
  module ActiveRecord
    module AttributeMethods
      module Write
        def self.included(base)
          alias []= write_attribute
          alias_method :raw_write_attribute, :write_attribute
        end

        def write_attribute(attr_name, value)
          if attr_name.kind_of?(Array)
            unless value.length == attr_name.length
              raise "Number of attr_names and values do not match"
            end
            [attr_name, value].transpose.map {|name,val| _write_attribute(name, val)}
            value
          else
            _write_attribute(attr_name, value)
          end
        end
        
        def _write_attribute(attr_name, value)
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
end