module ActiveRecord
  module AttributeMethods
    module Read
      def read_attribute(attr_name, &block)
        if attr_name.kind_of?(Array)
          attr_name.map {|name| read_attribute(name)}.to_composite_keys
        else
          name = attr_name.to_s
          name = self.class.primary_key if name == 'id'
          @attributes.fetch_value(name, &block)
        end
      end
    end
  end
end