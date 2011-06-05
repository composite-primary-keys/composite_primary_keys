require 'abstract_unit'

class TestAssociations < ActiveSupport::TestCase
  fixtures :articles, :products, :tariffs, :product_tariffs, :suburbs, :streets, :restaurants,
           :dorms, :rooms, :room_attributes, :room_attribute_assignments, :students, :room_assignments, :users, :readings,
           :departments, :memberships
  
  def test_count
    assert_equal(2, Product.count(:include => :product_tariffs))
    assert_equal(3, Tariff.count(:include => :product_tariffs))

    expected = {Date.today => 2,
                Date.today.next => 1}

    assert_equal(expected, Tariff.count(:group => :start_date))
  end

  def test_count_distinct
    product = products(:first_product)
    assert_equal(2, product.product_tariffs.count(:distinct => true))
  end

  def test_products
    assert_not_nil products(:first_product).product_tariffs
    assert_equal 2, products(:first_product).product_tariffs.length
    assert_not_nil products(:first_product).tariffs
    assert_equal 2, products(:first_product).tariffs.length
  end

  def test_product_tariffs
    assert_not_nil product_tariffs(:first_flat).product
    assert_not_nil product_tariffs(:first_flat).tariff
    assert_equal Product, product_tariffs(:first_flat).product.class
    assert_equal Tariff, product_tariffs(:first_flat).tariff.class
  end

  def test_tariffs
    assert_not_nil tariffs(:flat).product_tariffs
    assert_equal 1, tariffs(:flat).product_tariffs.length
    assert_not_nil tariffs(:flat).products
    assert_equal 1, tariffs(:flat).products.length
  end

  # Its not generating the instances of associated classes from the rows
  def test_find_includes_products
    # Old style
    products = Product.find(:all, :include => :product_tariffs)
    assert_equal(2, products.length)
    assert_equal(3, products.inject(0) {|sum, product| sum + product.product_tariffs.length})

    # New style
    products = Product.includes(:product_tariffs)
    assert_equal(2, products.length)
    assert_equal(3, products.inject(0) {|sum, product| sum + product.product_tariffs.length})
  end

  def test_find_includes_tariffs
    # Old style
    tariffs = Tariff.find(:all, :include => :product_tariffs)
    assert_equal(3, tariffs.length)
    assert_equal(3, tariffs.inject(0) {|sum, tariff| sum + tariff.product_tariffs.length})

    # New style
    tariffs = Tariff.includes(:product_tariffs)
    assert_equal(3, tariffs.length)
    assert_equal(3, tariffs.inject(0) {|sum, tariff| sum + tariff.product_tariffs.length})
  end

  def test_find_includes_product_tariffs_product
    # Old style
    product_tariffs = ProductTariff.find(:all, :include => :product)
    assert_not_nil(product_tariffs)
    assert_equal(3, product_tariffs.length)

    # New style
    product_tariffs = ProductTariff.includes(:product)
    assert_not_nil(product_tariffs)
    assert_equal(3, product_tariffs.length)
  end

  def test_find_includes_product_tariffs_tariff
    # Old style
    product_tariffs = ProductTariff.find(:all, :include => :tariff)
    assert_equal(3, product_tariffs.length)

    # New style
    product_tariffs = ProductTariff.includes(:tariff)
    assert_equal(3, product_tariffs.length)
  end

  def test_has_many_through
    products = Product.find(:all, :include => :tariffs)
    assert_equal(2, products.length)

    tarrifs_length = products.inject(0) {|sum, product| sum + product.tariffs.length}
    assert_equal(3, tarrifs_length)
  end

  def test_find_product_includes
    products = Product.find(:all, :include => {:product_tariffs => :tariff})
    assert_equal(2, products.length)

    product_tariffs_length = products.inject(0) {|sum, product| sum + product.product_tariffs.length}
    assert_equal(3, product_tariffs_length)
  end

  def test_find_tariffs_includes
    tariffs = Tariff.find(:all, :include => {:product_tariffs => :product})
    assert_equal(3, tariffs.length)

    product_tariffs_length = tariffs.inject(0) {|sum, tariff| sum + tariff.product_tariffs.length}
    assert_equal(3, product_tariffs_length)
  end

  def test_has_many_through_when_not_pre_loaded
  	student = Student.find(:first)
  	rooms = student.rooms
  	assert_equal(1, rooms.size)
  	assert_equal(1, rooms.first.dorm_id)
  	assert_equal(1, rooms.first.room_id)
  end

  def test_has_many_through_when_through_association_is_composite
    dorm = Dorm.find(:first)
    assert_equal(2, dorm.rooms.length)
    assert_equal(1, dorm.rooms.first.room_attributes.length)
    assert_equal('keg', dorm.rooms.first.room_attributes.first.name)
  end

  def test_associations_with_conditions
    suburb = Suburb.find([2, 1])
    assert_equal 2, suburb.streets.size

    suburb = Suburb.find([2, 1])
    assert_equal 1, suburb.first_streets.size

    suburb = Suburb.find([2, 1], :include => :streets)
    assert_equal 2, suburb.streets.size

    suburb = Suburb.find([2, 1], :include => :first_streets)
    assert_equal 1, suburb.first_streets.size
  end

  def test_composite_has_many_composites
    room = rooms(:branner_room_1)
    assert_equal(2, room.room_assignments.length)
    assert_equal(room_assignments(:jacksons_room), room.room_assignments[0])
    assert_equal(room_assignments(:bobs_room), room.room_assignments[1])
  end

  def test_composite_belongs_to_composite
    room_assignment = room_assignments(:jacksons_room)
    assert_equal(rooms(:branner_room_1), room_assignment.room)
  end

  def test_has_many_with_primary_key
    @membership = Membership.find([1, 1])
    assert_equal 2, @membership.reading.id
  end

  def test_has_one_with_composite
    # In this case a regular model has_one composite model
    department = departments(:engineering)
    assert_not_nil(department.head)
  end

  def test_has_many_with_primary_key
    @membership = Membership.find([1, 1])

    assert_equal 2, @membership.readings.size
  end

  def test_has_many_with_composite_key
    # In this case a regular model has_many composite models
    dorm = dorms(:branner)
    assert_equal(2, dorm.rooms.length)
    assert_equal(1, dorm.rooms[0].room_id)
    assert_equal(2, dorm.rooms[1].room_id)
  end

  def test_joins_has_many_with_primary_key
    @membership = Membership.find(:first, :joins => :readings, :conditions => { :readings => { :id => 1 } })

    assert_equal [1, 1], @membership.id
  end

  def test_joins_has_one_with_primary_key
    @membership = Membership.find(:first, :joins => :readings,
                                          :conditions => { :readings => { :id => 2 } })

    assert_equal [1, 1], @membership.id
  end

  def test_has_many_through_with_conditions_when_through_association_is_not_composite
    user = User.find(:first)
    assert_equal 1, user.articles.find(:all, :conditions => ["articles.name = ?", "Article One"]).size
  end

  def test_has_many_through_with_conditions_when_through_association_is_composite
    room = Room.find(:first)
    assert_equal 0, room.room_attributes.find(:all, :conditions => ["room_attributes.name != ?", "keg"]).size
  end

  def test_has_many_through_on_custom_finder_when_through_association_is_composite_finder_when_through_association_is_not_composite
    user = User.find(:first)
    assert_equal(1, user.find_custom_articles.size)
  end

  def test_has_many_through_on_custom_finder_when_through_association_is_composite
    room = Room.find(:first)
    assert_equal(0, room.find_custom_room_attributes.size)
  end

  def test_has_many_with_primary_key_with_associations
    # Trigger Active Records find_with_associations method
    memberships = Membership.find(:all, :include => :statuses,
                                        :conditions => ["membership_statuses.status = ?",
                                                        'Active'])

    assert_equal(1, memberships.length)
    assert_equal([1,1], memberships[0].id)
  end

  def test_limitable_reflections
    memberships = Membership.find(:all, :include => :statuses,
                                        :conditions => ["membership_statuses.status = ?",
                                                        'Active'],
                                        :limit => 1)
    assert_equal(1, memberships.length)
    assert_equal([1,1], memberships[0].id)
  end
end
