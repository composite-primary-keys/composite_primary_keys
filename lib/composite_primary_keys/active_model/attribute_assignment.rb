module ActiveModel
  module AttributeAssignment
    def _assign_attribute(k, v)
      # CPK. This is super ugly, but if a table has a composite key where one of the fields is named :id we need
      # to handle it as a single value. Otherwise, we would call the id=(value) method which is expecting
      # and array of values.
      if k == 'id' && self.kind_of?(ActiveRecord::Base) && self.composite? && !self.column_for_attribute(k).null
        self._write_attribute(k, v)
      else
        setter = :"#{k}="
        if respond_to?(setter)
          public_send(setter, v)
        else
          raise UnknownAttributeError.new(self, k)
        end
      end
    end
  end
end
