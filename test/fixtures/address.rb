class Address < ActiveRecord::Base
  self.primary_keys = :address_id, :user_id
  default_scope order(:sort_order)
end

