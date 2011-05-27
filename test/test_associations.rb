require 'abstract_unit'

class TestAssociations < ActiveSupport::TestCase
  fixtures :articles, :products, :tariffs, :product_tariffs, :suburbs, :streets, :restaurants, :restaurants_suburbs,
           :dorms, :rooms, :room_attributes, :room_attribute_assignments, :students, :room_assignments, :users, :readings,
           :memberships
  
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
    assert_equal 1, user.find_custom_articles.size
  end

  def test_has_many_through_on_custom_finder_when_through_association_is_composite
    room = Room.find(:first)
    assert_equal 0, room.find_custom_room_attributes.size
  end

  def test_count
    assert_equal(2, Product.count(:include => :product_tariffs))
    assert_equal(3, Tariff.count(:include => :product_tariffs))

    expected = {Date.today => 2,
                Date.today.next => 1}
       
    assert_equal(expected, Tariff.count(:group => :start_date))
  end

  def test_products
    assert_not_nil products(:first_product).product_tariffs
    assert_equal 2, products(:first_product).product_tariffs.length
    assert_not_nil products(:first_product).tariffs
    assert_equal 2, products(:first_product).tariffs.length
    assert_not_nil products(:first_product).product_tariff
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
    assert_not_nil tariffs(:flat).product_tariff
  end

  # Its not generating the instances of associated classes from the rows
  def test_find_includes_products
    # Old style
    assert @products = Product.find(:all, :include => :product_tariffs)
    assert_equal 2, @products.length
    assert_not_nil @products.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @products.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returned"

    # New style
    assert @products = Product.includes(:product_tariffs)
    assert_equal 2, @products.length
    assert_not_nil @products.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @products.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returned"
  end

  def test_find_includes_tariffs
    # Old style
    assert @tariffs = Tariff.find(:all, :include => :product_tariffs)
    assert_equal 3, @tariffs.length
    assert_not_nil @tariffs.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returnedturned"

    # New style
    assert @tariffs = Tariff.includes(:product_tariffs)
    assert_equal 3, @tariffs.length
    assert_not_nil @tariffs.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returnedturned"
  end

  def test_find_includes_product_tariffs
    # Old style
    assert @product_tariffs = ProductTariff.find(:all, :include => :product)
    assert_equal 3, @product_tariffs.length
    assert_not_nil @product_tariffs.first.instance_variable_get('@product'), '@product not set'

    # New style
    assert @product_tariffs = ProductTariff.includes(:product)
    assert_equal 3, @product_tariffs.length
    assert_not_nil @product_tariffs.first.instance_variable_get('@product'), '@product not set'
  end

  def test_find_includes_comp_belongs_to_tariff
    # Old style
    assert @product_tariffs = ProductTariff.find(:all, :include => :tariff)
    assert_equal 3, @product_tariffs.length
    assert_not_nil @product_tariffs.first.instance_variable_get('@tariff'), '@tariff not set'

    # New style
    assert @product_tariffs = ProductTariff.includes(:tariff)
    assert_equal 3, @product_tariffs.length
    assert_not_nil @product_tariffs.first.instance_variable_get('@tariff'), '@tariff not set'
  end

  def test_find_includes_extended
    assert @products = Product.find(:all, :include => {:product_tariffs => :tariff})
    assert_equal 3, @products.inject(0) {|sum, product| sum + product.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returned"

    assert @tariffs = Tariff.find(:all, :include => {:product_tariffs => :product})
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returned"
  end

  def test_has_many_through
    @products = Product.find(:all, :include => :tariffs)
    assert_equal 3, @products.inject(0) {|sum, product| sum + product.instance_variable_get('@tariffs').length},
      "Incorrect number of tariffs returned"
  end

  def test_has_many_through_when_not_pre_loaded
  	student = Student.find(:first)
  	rooms = student.rooms
  	assert_equal 1, rooms.size
  	assert_equal 1, rooms.first.dorm_id
  	assert_equal 1, rooms.first.room_id
  end

  def test_has_many_through_when_through_association_is_composite
    dorm = Dorm.find(:first)
    assert_equal 1, dorm.rooms.length
    assert_equal 1, dorm.rooms.first.room_attributes.length
    assert_equal 'keg', dorm.rooms.first.room_attributes.first.name
  end

  def test_associations_with_conditions
    @suburb = Suburb.find([2, 1])
    assert_equal 2, @suburb.streets.size

    @suburb = Suburb.find([2, 1])
    assert_equal 1, @suburb.first_streets.size

    @suburb = Suburb.find([2, 1], :include => :streets)
    assert_equal 2, @suburb.streets.size

    @suburb = Suburb.find([2, 1], :include => :first_streets)
    assert_equal 1, @suburb.first_streets.size
  end

  def test_has_and_belongs_to_many
    @restaurant = Restaurant.find([1,1])
    assert_equal 2, @restaurant.suburbs.size

    @restaurant = Restaurant.find([1,1], :include => :suburbs)
    assert_equal 2, @restaurant.suburbs.size
  end

  def test_hbtm_clear
    @restaurant = Restaurant.find([1,1])
    assert_equal 2, @restaurant.suburbs.size
    @restaurant.suburbs.clear
    @restaurant = Restaurant.find([1,1])
    assert_equal 0, @restaurant.suburbs.size
  end

  def test_has_many_with_primary_key
    @membership = Membership.find([1, 1])

    assert_equal 2, @membership.readings.size
  end

  def test_has_one_with_primary_key
    @membership = Membership.find([1, 1])

    assert_equal 2, @membership.reading.id
  end

  def test_joins_has_many_with_primary_key
    @membership = Membership.find(:first, :joins => :readings, :conditions => { :readings => { :id => 1 } })

    assert_equal [1, 1], @membership.id
  end

  def test_joins_has_one_with_primary_key
    @membership = Membership.find(:first, :joins => :reading, :conditions => { :readings => { :id => 2 } })

    assert_equal [1, 1], @membership.id
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
