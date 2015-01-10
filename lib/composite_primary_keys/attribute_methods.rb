module ActiveRecord
  module AttributeMethods
    def has_attribute?(attr_name)
      # CPK
      # @attributes.key?(attr_name.to_s)
      Array(attr_name).all?{|single_attr| @attributes.key?(single_attr.to_s) }
    end
  end
end
