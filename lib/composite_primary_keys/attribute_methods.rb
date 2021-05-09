module ActiveRecord
  module AttributeMethods
    def has_attribute?(attr_name)
      # CPK
      # attr_name = attr_name.to_s
      # attr_name = self.class.attribute_aliases[attr_name] || attr_name
      # @attributes.key?(attr_name)
      Array(attr_name).all? do |attr|
        attr = attr.to_s
        attr = self.class.attribute_aliases[attr] || attr
        @attributes.key?(attr)
      end
    end

    def _has_attribute?(attr_name)
      # CPK
      # @attributes.key?(attr_name)
      Array(attr_name).all? { |attr| @attributes.key?(attr) }
    end
  end
end
