class Room < ActiveRecord::Base
  set_primary_keys :dorm_id, :room_id
  belongs_to :dorm
  has_many :room_attribute_assignments, :foreign_key =>  [:dorm_id, :room_id]
  has_many :room_attributes, :through => :room_attribute_assignments
end