require File.expand_path('../abstract_unit', __FILE__)

class TestHasOneThrough < ActiveSupport::TestCase
  fixtures :users, :rooms

  def test_no_cpk
    # This test makes sure we don't break anything in standard rails by using CPK
    user = User.find(1)
    assert_nil user.moderator
    assert_nil user.admin

    admin = Admin.create!(user: user)
    assert_equal admin, user.admin
    assert_equal 1, user.moderator.id
    assert_equal 1, admin.id
  end

  def test_has_one_through
    room = Room.find([1,1])
    assert_nil room.staff_room
    assert_nil room.staff_room_key

    key = StaffRoomKey.create!(room: room, key_no: '1234')
    assert_equal key, room.staff_room_key
    assert_equal 1, room.staff_room.dorm_id
    assert_equal 1, room.staff_room.room_id
    assert_equal 1, key.dorm_id
    assert_equal 1, key.room_id
  end
end
