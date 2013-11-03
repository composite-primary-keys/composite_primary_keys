require File.expand_path('../abstract_unit', __FILE__)

class TestEqual < ActiveSupport::TestCase
  fixtures :departments

  def test_json
    department = Department.first
    assert_equal('{"department_id":1,"location_id":1}', department.to_json)
  end
end