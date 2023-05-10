class StaffRoom < ActiveRecord::Base
  self.primary_keys = :dorm_id, :room_id

  belongs_to :room, :foreign_key => [:dorm_id, :room_id], :inverse_of => :staff_room
  has_one :staff_room_key, :foreign_key => [:dorm_id, :room_id], :inverse_of => :staff_room
end
