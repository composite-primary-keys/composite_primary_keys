class Capitol < ActiveRecord::Base
  set_primary_keys :country, :city
end
