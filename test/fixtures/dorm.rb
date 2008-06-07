class Dorm < ActiveRecord::Base
  has_many :rooms, :include => :room_attributes
end