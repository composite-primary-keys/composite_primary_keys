class Seat < ActiveRecord::Base
  set_primary_keys [:flight_number, :seat]

  validates_uniqueness_of :customer
end
