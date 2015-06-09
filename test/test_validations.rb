require File.expand_path('../abstract_unit', __FILE__)

class TestValidations < ActiveSupport::TestCase
  fixtures :students, :dorms, :rooms, :room_assignments

  def test_uniqueness_validation_persisted
    room_assignment = RoomAssignment.find([1, 1, 1])
    assert(room_assignment.valid?)

    room_assignment = RoomAssignment.new(:student_id => 1, :dorm_id => 1, :room_id => 2)
    assert(!room_assignment.valid?)
  end

  def test_validate_uniqueness_with_conditions
    Comment.validates(:person_type, uniqueness: { scope: :person_id, conditions: -> { where(:shown => 1)} })
    t1 = Comment.create("shown" => 0, "person_id" => 123, :person_type => 'robot')

    t2 = Comment.new("shown" => 1, "person_id" => 123, :person_type => 'robot')
    assert t2.valid?, "t4 should be valid"
  end
end
