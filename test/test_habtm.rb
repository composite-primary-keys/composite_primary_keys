require 'abstract_unit'

class TestHabtm < ActiveSupport::TestCase

  fixtures :suburbs, :restaurants, :restaurants_suburbs, :products

  def test_has_and_belongs_to_many
    @restaurant = Restaurant.find([1,1])
    assert_equal 2, @restaurant.suburbs.size

    @restaurant = Restaurant.find([1,1], :include => :suburbs)
    assert_equal 2, @restaurant.suburbs.size
  end

  def test_habtm_clear_cpk_both_sides
    @restaurant = restaurants(:mcdonalds)
    assert_equal 2, @restaurant.suburbs.size
    @restaurant.suburbs.clear
    assert_equal 0, @restaurant.suburbs.size
  end

  def test_habtm_clear_cpk_owner_side_only
    subway = restaurants(:subway_one)
    first_product = products(:first_product)
    second_product = products(:second_product)
    subway.products << first_product << second_product
    assert_equal 2, subway.products.size
    subway.products.clear
    assert_equal 0, subway.products.size
  end

  def test_habtm_clear_cpk_association_side_only
    product = products(:first_product)
    subway_one = restaurants(:subway_one)
    subway_two = restaurants(:subway_two)
    product.restaurants << subway_one << subway_two
    assert_equal 2, product.restaurants.size
    product.restaurants.clear
    assert_equal 0, product.restaurants.size
  end

end
