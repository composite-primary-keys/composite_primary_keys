module ActiveModel
  module Dirty
    def attribute_was(attr)
      # CPK
      if self.composite? && attr == "id"
        self.class.primary_keys.map do |key_attr|
          attribute_changed?(key_attr) ? changed_attributes[key_attr] : self.ids_hash[key_attr]
        end
      else
        attribute_changed?(attr) ? changed_attributes[attr] : __send__(attr)
      end
    end
  end
end