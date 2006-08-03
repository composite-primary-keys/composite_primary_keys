class Suburb < ActiveRecord::Base
  set_primary_keys :city_id, :suburb_id
  has_many :streets,  :foreign_key => [:city_id, :suburb_id]
end