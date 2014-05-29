module ActiveModel
  module Dirty
    def attribute_was(attr)
      # CPK
      if self.composite? && attr == "id"
        self.class.primary_keys.map do |attr|
          attribute_changed?(attr) ? changed_attributes[attr] : self.ids_hash[attr]
        end
      else
        attribute_changed?(attr) ? changed_attributes[attr] : __send__(attr)
      end
    end
  end
end