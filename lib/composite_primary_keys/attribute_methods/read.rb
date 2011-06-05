module ActiveRecord
  module AttributeMethods
    module Read
      module ClassMethods
        def define_read_method(method_name, attr_name, column)
          cast_code = column.type_cast_code('v')
          # CPK - this is a really horrid hack, needed to get
          # right class namespace :(
          if cast_code.match(/^ActiveRecord/)
            cast_code = "::#{cast_code}"
          end

          access_code = "(v=@attributes['#{attr_name}']) && #{cast_code}"

          # CPK
          # unless attr_name.to_s == self.primary_key.to_s
          #   access_code.insert(0, "missing_attribute('#{attr_name}', caller) unless @attributes.has_key?('#{attr_name}'); ")
          # end
          primary_keys = Array(self.primary_key)

          unless primary_keys.include?(attr_name.to_s)
            access_code = access_code.insert(0, "missing_attribute('#{attr_name}', caller) unless @attributes.has_key?('#{attr_name}'); ")
          end

          if cache_attribute?(attr_name)
            access_code = "@attributes_cache['#{attr_name}'] ||= (#{access_code})"
          end

          # Where possible, generate the method by evalling a string, as this will result in
          # faster accesses because it avoids the block eval and then string eval incurred
          # by the second branch.
          #
          # The second, slower, branch is necessary to support instances where the database
          # returns columns with extra stuff in (like 'my_column(omg)').
          if method_name =~ ActiveModel::AttributeMethods::COMPILABLE_REGEXP
            generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__
              def _#{method_name}
                #{access_code}
              end

              alias #{method_name} _#{method_name}
            STR
          else
            generated_attribute_methods.module_eval do
              define_method("_#{method_name}") { eval(access_code) }
              alias_method(method_name, "_#{method_name}")
            end
          end
        end
      end

      def read_attribute(attr_name)
        # CPK
        if attr_name.kind_of?(Array)
          attr_name.map {|name| read_attribute(name)}.to_composite_keys
        elsif respond_to? "_#{attr_name}"
          send "_#{attr_name}" if @attributes.has_key?(attr_name.to_s)
        else
          _read_attribute attr_name
        end
      end


      def _read_attribute(attr_name)
        attr_name = attr_name.to_s
        # CPK
        # attr_name = self.class.primary_key if attr_name == 'id'
        attr_name = self.class.primary_key if (attr_name == 'id' and !self.composite?)
        value = @attributes[attr_name]
        unless value.nil?
          if column = column_for_attribute(attr_name)
            if unserializable_attribute?(attr_name, column)
              unserialize_attribute(attr_name)
            else
              column.type_cast(value)
            end
          else
            value
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[] :read_attribute
end