require File.expand_path('../abstract_unit', __FILE__)

class TestCalculations < ActiveSupport::TestCase
  fixtures :articles, :products, :tariffs, :product_tariffs, :suburbs, :streets, :restaurants,
           :dorms, :rooms, :room_attributes, :room_attribute_assignments, :students, :room_assignments, :users, :readings,
           :departments, :employees, :memberships, :membership_statuses

  def test_count
    assert_equal(3, Product.count(:include => :product_tariffs))
    assert_equal(3, Tariff.count(:include => :product_tariffs))

    expected = {Date.today => 2,
                Date.today.next => 1}

    assert_equal(expected, Tariff.count(:group => :start_date))
  end

  def test_count_distinct
    product = products(:first_product)
    assert_equal(1, product.product_tariffs.select('tariff_start_date').count(:distinct => true))
  end
  
  def test_count_not_distinct
    product = products(:first_product)
    assert_equal(2, product.product_tariffs.select('tariff_start_date').count(:distinct => false))
  end

  def test_count_includes
    count = Dorm.count(:include => :rooms,
                       :conditions => ["rooms.room_id = ?", 2])
    assert_equal(1, count)
  end

  def test_count_includes_dup_columns
    count = Tariff.includes(:product_tariffs).where("product_tariffs.tariff_id = ?", 2).count
    assert_equal(1, count)
  end
end