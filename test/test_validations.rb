require './abstract_unit'

class TestValidations < ActiveSupport::TestCase
  fixtures :seats

  def test_uniqueness_validation_persisted
    seat = Seat.find([1,1])
    assert(seat.valid?)

    seat.customer = 2
    assert(!seat.valid?)
  end
end
