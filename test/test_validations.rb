require 'abstract_unit'
require 'fixtures/seat'

class TestValidations < ActiveSupport::TestCase
  fixtures :seats

  def test_uniqueness_validation_on_saved_record
    s = Seat.find([1,1])
    assert s.valid?
  end
end
