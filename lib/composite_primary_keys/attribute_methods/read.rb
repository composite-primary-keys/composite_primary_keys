module ActiveRecord
  module AttributeMethods
    module Read
      module ClassMethods
        def internal_attribute_access_code(attr_name, cast_code)
          # CPK - this is a really horrid hack, needed to get
          # right class namespace :(
          if cast_code.match(/^ActiveRecord/)
            cast_code = "::#{cast_code}"
          end
          access_code = "(v=@attributes[attr_name]) && #{cast_code}"

          # CPK
          #unless attr_name == primary_key
          primary_keys = Array(self.primary_key)
          unless primary_keys.include?(attr_name.to_s)
            access_code.insert(0, "missing_attribute(attr_name, caller) unless @attributes.has_key?(attr_name); ")
          end

          if cache_attribute?(attr_name)
            access_code = "@attributes_cache[attr_name] ||= (#{access_code})"
          end

          "attr_name = '#{attr_name}'; #{access_code}"
        end
      end

      def read_attribute(attr_name)
        # CPK
        if attr_name.kind_of?(Array)
          attr_name.map {|name| read_attribute(name)}.to_composite_keys
        else
          self.class.type_cast_attribute(attr_name, @attributes, @attributes_cache)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  alias :[] :read_attribute
end
