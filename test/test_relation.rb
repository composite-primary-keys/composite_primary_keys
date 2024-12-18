require File.expand_path('../abstract_unit', __FILE__)

class TestRelation < ActiveSupport::TestCase
  fixtures :users, :readings
  
  def test_update_all_updates_db_records
    user = User.find(1)
    assert_equal [4, 5], user.readings.map(&:rating)

    user.readings.update_all(rating: 3)

    # Reload to check that the records were updated in the DB
    user.readings.reload
    assert_equal [3, 3], user.readings.map(&:rating)
  end

  def test_update_all_updates_loaded_association
    user = User.find(1)
    assert_equal [4, 5], user.readings.map(&:rating)

    user.readings.update_all(rating: 3)

    # No reload to check that not only the records were updated in the DB
    # but also in the loaded association
    assert_equal [3, 3], user.readings.map(&:rating)
  end
end
