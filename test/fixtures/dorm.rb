class Dorm < ActiveRecord::Base
  has_many :rooms, :include => :room_attributes, :primary_key => [:id]
end