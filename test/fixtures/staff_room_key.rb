class StaffRoomKey < ActiveRecord::Base
  self.primary_keys = :dorm_id, :room_id

  belongs_to :staff_room, :foreign_key => [:dorm_id, :room_id], :inverse_of => :staff_room_key
  has_one :room, :through => :staff_room
end
