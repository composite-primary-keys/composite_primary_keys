module ActiveRecord
  module Sanitization
    def quoted_id
      # CPK
      #quote_value(id, column_for_attribute(self.class.primary_key))
      [self.class.primary_keys, ids].
        transpose.
        map {|attr_name,id| quote_value(id, column_for_attribute(attr_name))}
    end
  end
end