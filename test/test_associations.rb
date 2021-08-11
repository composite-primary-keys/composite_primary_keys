require File.expand_path('../abstract_unit', __FILE__)

class TestAssociations < ActiveSupport::TestCase
  fixtures :articles, :products, :tariffs, :product_tariffs, :suburbs, :streets, :restaurants,
           :dorms, :rooms, :room_attributes, :room_attribute_assignments, :students, :room_assignments, :users, :readings,
           :departments, :employees, :memberships, :membership_statuses

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
  def test_find_includes
    products = Product.includes(:product_tariffs)
    assert_equal(3, products.length)
    assert_equal(3, products.inject(0) {|sum, product| sum + product.product_tariffs.length})
  end

  def test_find_includes_2
    products = ProductTariff.where(:tariff_id => 2).order('product_id, tariff_id').includes(:tariff)
    assert_equal(2, products.length)
  end

  def test_find_includes_eager_loading
    product = products(:second_product)
    product_tarrif = product_tariffs(:second_free)

    # First get a legitimate product tarrif
    products = Product.includes(:product_tariffs).where('product_tariffs.product_id = ?', product.id).references(:product_tariffs)
    assert_equal(1, products.length)
    assert_equal(product, products.first)
    assert_equal([product_tarrif], products.first.product_tariffs)
  end

  def test_find_eager_loading_none
    product = products(:third_product)

    products = Product.includes(:product_tariffs).where(:id => product.id).references(:product_tariffs)
    assert_equal(1, products.length)
    assert_equal(product, products.first)
    assert_empty(products.first.product_tariffs)
  end

  def test_find_includes_tariffs
    tariffs = Tariff.includes(:product_tariffs)
    assert_equal(3, tariffs.length)
    assert_equal(3, tariffs.inject(0) {|sum, tariff| sum + tariff.product_tariffs.length})
  end

  def test_find_each_does_not_throw_error
    tariffs = Tariff.includes(:product_tariffs)
    worked = false
    tariffs.first.product_tariffs.order(:tariff_id).find_each do |pt|
      worked = true
    end
    assert worked
  end

  def test_association_with_composite_primary_key_can_be_autosaved
    room = Room.new(dorm_id: 1000, room_id: 1001)
    room_assignment = RoomAssignment.new(student_id: 1000)
    room_assignment.room = room
    room_assignment.save
    room_assignment.reload
    assert_equal(room_assignment.dorm_id, 1000)
    assert_equal(room_assignment.room_id, 1001)
  end

  def test_has_one_association_is_not_cached_to_where_it_returns_the_wrong_one
    engineering = departments(:engineering)
    engineering_head = engineering.head
    assert_equal(employees(:sarah), engineering_head)

    accounting = departments(:accounting)
    accounting_head = accounting.head
    assert_equal(employees(:steve), accounting_head)

    refute_equal accounting_head, engineering_head
  end

  def test_has_one_association_primary_key_and_foreign_key_are_present
    # department = departments(:engineering)
    # assert_equal(2, department.employees.count)
    # assert_equal('Sarah', department.employees[0].name)
    # assert_equal('Robert', department.employees[1].name)
    # assert_equal('Sarah', department.head.name)

    department = departments(:human_resources)
    assert_equal(1, department.employees.count)
    assert_equal('Mindy', department.employees[0].name)
    assert_equal('Mindy', department.head.name)

    head = department.create_head(name: 'Rick')
    assert_equal(department, head.department)
    assert_equal('Rick', department.head.name)

    department.reload
    assert_equal(1, department.employees.count)
  end

  def test_has_one_autosave
    department = departments(:engineering)
    assert_equal('Sarah', department.head.name)

    department.head.name = 'Sarah1'
    department.save!
    assert_equal('Sarah1', department.head.name)
  end

  def test_has_many_association_is_not_cached_to_where_it_returns_the_wrong_ones
    engineering = departments(:engineering)
    engineering_employees = engineering.employees

    accounting = departments(:accounting)
    accounting_employees = accounting.employees

    refute_equal accounting_employees, engineering_employees
  end

  def test_has_many_association_primary_key_and_foreign_key_are_present
    department = departments(:accounting)
    assert_equal(2, department.employees.count)
    assert_equal('Steve', department.employees[0].name)
    assert_equal('Jill', department.employees[1].name)

    department.employees.create(name: 'Rick')

    department.reload
    assert_equal(3, department.employees.count)
    employees = department.employees.sort_by(&:name)
    assert_equal('Jill', employees[0].name)
    assert_equal('Rick', employees[1].name)
    assert_equal('Steve', employees[2].name)
  end

  def test_find_includes_product_tariffs_product
    # Old style
    product_tariffs = ProductTariff.includes(:product)
    assert_not_nil(product_tariffs)
    assert_equal(3, product_tariffs.length)

    # New style
    product_tariffs = ProductTariff.includes(:product)
    assert_not_nil(product_tariffs)
    assert_equal(3, product_tariffs.length)
  end

  def test_find_includes_product_tariffs_tariff
    # Old style
    product_tariffs = ProductTariff.includes(:tariff)
    assert_equal(3, product_tariffs.length)

    # New style
    product_tariffs = ProductTariff.includes(:tariff)
    assert_equal(3, product_tariffs.length)
  end

  def test_has_many_through
    products = Product.includes(:tariffs)
    assert_equal(3, products.length)

    tarrifs_length = products.inject(0) {|sum, product| sum + product.tariffs.length}
    assert_equal(3, tarrifs_length)
  end

  def test_has_many_through_2
    assert_equal(3, Article.count)
    user = users(:santiago)
    article_names = user.articles.map(&:name).sort
    assert_equal(['Article One', 'Article Two'], article_names)
  end

  def test_new_style_includes_with_conditions
    product_tariff = ProductTariff.includes(:tariff).where('tariffs.amount < 5').references(:tariffs).first
    assert_equal(0, product_tariff.tariff.amount)
  end

  def test_find_product_includes
    products = Product.includes(:product_tariffs => :tariff)
    assert_equal(3, products.length)

    product_tariffs_length = products.inject(0) {|sum, product| sum + product.product_tariffs.length}
    assert_equal(3, product_tariffs_length)
  end

  def test_has_many_through_when_not_pre_loaded
    student = Student.first
    rooms = student.rooms
    assert_equal(1, rooms.size)
    assert_equal(1, rooms.first.dorm_id)
    assert_equal(1, rooms.first.room_id)
  end

  def test_has_many_through_when_through_association_is_composite
    dorm = Dorm.first
    assert_equal(3, dorm.rooms.length)
    assert_equal(1, dorm.rooms.first.room_attributes.length)
    assert_equal('type', dorm.rooms.first.room_attributes.first.name)
  end

  def test_associations_with_conditions
    suburb = Suburb.find([2, 2])
    assert_equal 2, suburb.streets.size
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

  def test_composite_belongs_to_changes
    room_assignment = room_assignments(:jacksons_room)
    room_assignment.room = rooms(:branner_room_2)
    # This was raising an error before:
    #   TypeError: [:dorm_id, :room_id] is not a symbol
    # changes returns HashWithIndifferentAccess
    assert_equal({"room_id"=>[1, 2]}, room_assignment.changes)

    steve = employees(:steve)
    steve.department = departments(:engineering)
    # It was returning this before:
    #   {"[:id, :location_id]"=>[nil, [2, 1]]}
    assert_equal({"department_id"=>[1, 2]}, steve.changes)
  end

  def test_composite_belongs_to_setting_to_nil
    room_assignment = room_assignments(:jacksons_room)
    # This was raising an error before:
    #   NoMethodError: undefined method `length' for nil:NilClass
    assert_nothing_raised { room_assignment.room = nil }
  end

  def test_has_one_with_composite
    # In this case a regular model has_one composite model
    department = departments(:engineering)
    assert_not_nil(department.head)
  end

  def test_has_many_build_simple_key
    user = users(:santiago)
    reading = user.readings.build
    assert_equal user.id, reading.user_id
    assert_equal user,    reading.user
  end

  def test_has_many_build_composite_key
    department = departments(:engineering)
    employee = department.employees.build
    assert_equal(department[:id], employee.department_id)
    assert_equal(department.location_id, employee.location_id)
    assert_equal(department, employee.department)
  end

  def test_has_many_with_primary_key
    @membership = Membership.find([1, 1])
    assert_equal 2, @membership.readings.size
  end

  def test_has_many_with_composite_key
    # In this case a regular model (Dorm) has_many composite models (Rooms)
    dorm = dorms(:branner)
    assert_equal(3, dorm.rooms.length)
    assert_equal(1, dorm.rooms[0].room_id)
    assert_equal(2, dorm.rooms[1].room_id)
    assert_equal(3, dorm.rooms[2].room_id)
  end

  def test_has_many_with_foreign_composite_key
    tariff = Tariff.find_by('tariff_id = ?', 2)
    assert_equal(2, tariff.product_tariffs.length)
  end

  def test_joins_has_many_with_primary_key
    #@membership = Membership.find(:first, :joins => :readings, :conditions => { :readings => { :id => 1 } })
    @membership = Membership.joins(:readings).where(readings: { id: 1 }).first

    assert_equal [1, 1], @membership.id
  end

  def test_joins_has_one_with_primary_key
    @membership = Membership.joins(:readings).where(readings: { id: 2 }).first

    assert_equal [1, 1], @membership.id
  end

  def test_has_many_through_with_conditions_when_through_association_is_not_composite
    user = User.first
    assert_equal 1, user.articles.where("articles.name = ?", "Article One").size
  end

  def test_has_many_through_with_conditions_when_through_association_is_composite
    room = Room.first
    assert_equal 0, room.room_attributes.where("room_attributes.name != ?", "type").size
  end

  def test_has_many_through_on_custom_finder_when_through_association_is_composite_finder_when_through_association_is_not_composite
    user = User.first
    assert_equal(1, user.find_custom_articles.size)
  end

  def test_has_many_through_on_custom_finder_when_through_association_is_composite
    room = Room.first
    assert_equal(0, room.find_custom_room_attributes.size)
  end

  def test_has_many_with_primary_key_with_associations
    memberships = Membership.includes(:statuses).where("membership_statuses.status = ?", 'Active').references(:membership_statuses)
    assert_equal(2, memberships.length)
    assert_equal([1,1], memberships[0].id)
    assert_equal([3,2], memberships[1].id)
  end

  def test_limitable_reflections
    memberships = Membership.includes(:statuses).where("membership_statuses.status = ?", 'Active').references(:membership_statuses)
    assert_equal(2, memberships.length)

    assert_equal([1,1], memberships[0].id)
    assert_equal([3,2], memberships[1].id)
  end

  def test_scoped_has_many_with_primary_key_with_associations
    puts Membership.joins(:active_statuses).to_sql
    memberships = Membership.joins(:active_statuses)
    assert_equal(2, memberships.length)
    assert_equal([1,1], memberships[0].id)
    assert_equal([3,2], memberships[1].id)
  end

  def test_foreign_key_present_with_null_association_ids
    group = Group.new
    group.memberships.build
    associations = group.association(:memberships)
    assert_equal(false, associations.send('foreign_key_present?'))
  end

  def test_ids_equals_for_non_CPK_case
    article = Article.new
    article.reading_ids = Reading.pluck(:id)
    assert_equal article.reading_ids, Reading.pluck(:id)
  end

  def test_find_by_association
    assert_equal Membership.where(user: '1').count, 1
    assert_equal Membership.where(user_id: '1').count, 1
    assert_equal Membership.where(user: User.find(1)).count, 1
  end
end
