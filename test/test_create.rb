require File.expand_path('../abstract_unit', __FILE__)

class TestCreate < ActiveSupport::TestCase
  fixtures :articles, :students, :dorms, :rooms, :room_assignments, :reference_types, :reference_codes, :streets, :suburbs

  CLASSES = {
    :single => {
      :class => ReferenceType,
      :primary_keys => :reference_type_id,
      :create => {:reference_type_id => 10, :type_label => 'NEW_TYPE', :abbreviation => 'New Type'}
    },
    :dual   => {
      :class => ReferenceCode,
      :primary_keys => [:reference_type_id, :reference_code],
      :create => {:reference_type_id => 1, :reference_code => 20, :code_label => 'NEW_CODE', :abbreviation => 'New Code'}
    }
  }

  def setup
    self.class.classes = CLASSES
  end

  def test_setup
    testing_with do
      assert_not_nil @klass_info[:create]
    end
  end

  def test_create
    testing_with do
      assert new_obj = @klass.create(@klass_info[:create])
      assert !new_obj.new_record?
      assert new_obj.id
      assert new_obj.previously_new_record?
    end
  end

  def test_create_no_id
    testing_with do
      begin
        @obj = @klass.create(@klass_info[:create].except(@klass.primary_key))
        @successful = !composite?
      rescue ActiveRecord::CompositeKeyError
        @successful = false
      rescue
        flunk "Incorrect exception raised: #{$!}, #{$!.class}"
      end
      assert_equal composite?, !@successful, "Create should have failed for composites; #{@obj.inspect}"
    end
  end

  def test_create_with_array
    date = Date.new(2027, 01, 27)
    tariff = Tariff.create!(id: [10, date], amount: 27)
    refute_nil(tariff)
    assert_equal([10, date], tariff.id)
    assert_equal(date, tariff.start_date)
    assert_equal(27, tariff.amount)
  end

  def test_create_with_partial_serial
    attributes = {:location_id => 100}

    # SQLite does not support an autoincrementing field in a composite key
    if Department.connection.class.name == "ActiveRecord::ConnectionAdapters::SQLite3Adapter"
      attributes[:id] = 200
    end

    department = Department.new(attributes)
    assert_nil(department.attributes[:id])

    department.save!
    refute_nil(department.attributes["id"])
    assert_equal(100, department.location_id)
  end

  def test_create_with_id
    department = Department.create!(id: [2, 3])
    assert_equal([2, 3], department.id)
    assert_equal(2, department.attributes["id"])
    assert_equal(3, department.attributes["location_id"])

    department.reload
    assert_equal([2, 3], department.id)
    assert_equal(2, department.attributes["id"])
    assert_equal(3, department.attributes["location_id"])
  end

  def test_create_on_association
    suburb = Suburb.first
    suburb.streets.create(:name => "my street")
    street = Street.find_by_name('my street')
    assert_equal(suburb.city_id, street.city_id)
    assert_equal(suburb.suburb_id, street.suburb_id)
  end

  def test_create_on_association_when_belongs_to_is_single_key
    rt = ReferenceType.first
    rt.reference_codes.create(:reference_code => 4321, :code_label => 'foo', :abbreviation => 'bar')
    rc = ReferenceCode.find_by_reference_code(4321)
    assert_equal(rc.reference_type_id, rt.reference_type_id)
  end

  def test_new_habtm
    restaurant = Restaurant.new(:franchise_id => 101,
                                :store_id => 201,
                                :name => "My Store")

    restaurant.suburbs << Suburb.new(:city_id => 24,
                                     :suburb_id => 25,
                                     :name => "My Suburb")

    restaurant.save!

    # Test restaurant
    assert_equal(101, restaurant.franchise_id)
    assert_equal(201, restaurant.store_id)
    assert_equal("My Store", restaurant.name)
    assert_equal(1, restaurant.suburbs.length)

    # Test suburbs
    suburb = restaurant.suburbs[0]
    assert_equal(24, suburb.city_id)
    assert_equal(25, suburb.suburb_id)
    assert_equal("My Suburb", suburb.name)
  end

  def test_create_habtm
    restaurant = Restaurant.create(:franchise_id => 100,
                                   :store_id => 200,
                                   :name => "My Store")

    restaurant.suburbs.create(:city_id => 24,
                              :suburb_id => 25,
                              :name => "My Suburb")

    # Test restaurant
    assert_equal(100, restaurant.franchise_id)
    assert_equal(200, restaurant.store_id)
    assert_equal("My Store", restaurant.name)

    assert_equal(1, restaurant.suburbs.reload.length)

    # Test suburbs
    suburb = restaurant.suburbs[0]
    assert_equal(24, suburb.city_id)
    assert_equal(25, suburb.suburb_id)
    assert_equal("My Suburb", suburb.name)
  end

  def test_has_many_ids_1
    dorm = dorms(:toyon)
    room = Room.new(:dorm_id => dorm.id, :room_id => 5)
    room.save!

    student1 = students(:kelly)

    RoomAssignment.delete_all

    assignment1 = RoomAssignment.new(:student_id => student1.id, :dorm_id => room.dorm_id, :room_id => room.room_id)
    assignment1.save!

    room.room_assignment_ids = [[assignment1.student_id, assignment1.dorm_id, assignment1.room_id]]
    room.save!

    assert_equal(1, room.room_assignments.length)
    assert_equal(assignment1, room.room_assignments.first)
  end

  def test_has_many_ids_2
    dorm = dorms(:toyon)
    room = Room.new(:dorm_id => dorm.id, :room_id => 5)
    room.save!

    student1 = students(:kelly)
    student2 = students(:jordan)

    RoomAssignment.delete_all

    assignment1 = RoomAssignment.new(:student_id => student1.id, :dorm_id => room.dorm_id, :room_id => room.room_id)
    assignment1.save!

    assignment2 = RoomAssignment.new(:student_id => student2.id, :dorm_id => room.dorm_id, :room_id => room.room_id)
    assignment2.save!

    room.room_assignment_ids = [[assignment1.student_id, assignment1.dorm_id, assignment1.room_id],
                                [assignment2.student_id, assignment2.dorm_id, assignment2.room_id]]
    room.save!

    assert_equal(2, room.room_assignments.length)
    assert_equal(assignment1, room.room_assignments[0])
    assert_equal(assignment2, room.room_assignments[1])
  end

  def test_find_or_create_by
    suburb = Suburb.find_by(:city_id => 3, :suburb_id => 1)
    assert_nil(suburb)

    suburb = Suburb.find_or_create_by!(:name => 'New Suburb', :city_id => 3, :suburb_id => 1)
    refute_nil(suburb)
  end

  def test_cache
    Suburb.cache do
      # Suburb does not exist
      suburb = Suburb.find_by(:city_id => 10, :suburb_id => 10)
      assert_nil(suburb)

      # Create it
      suburb = Suburb.create!(:name => 'New Suburb', :city_id => 10, :suburb_id => 10)

      # Should be able to find it
      suburb = Suburb.find_by(:city_id => 10)
      refute_nil(suburb)
      refute_nil(suburb.city_id)
      refute_nil(suburb.suburb_id)
    end
  end
end
