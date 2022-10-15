class RoomAssignment < ActiveRecord::Base
  self.primary_keys = :student_id, :dorm_id, :room_id
  belongs_to :student
  belongs_to :room, :foreign_key => [:dorm_id, :room_id], :primary_key => [:dorm_id, :room_id]
  validates :student_id, uniqueness: {
    conditions: ->(record) {
      where(student_id: record.student_id) # enough just to exercise this code path
    }
  }

  before_destroy do |record|
    puts record
  end

  after_destroy do |record|
    puts record
  end
end
