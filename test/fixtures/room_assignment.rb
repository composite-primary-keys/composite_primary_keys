class RoomAssignment < ActiveRecord::Base
  belongs_to :student
  belongs_to :room, :foreign_key => [:dorm_id, :room_id]
end