require 'abstract_unit'
require 'ruby-debug'

class TestHabtm < ActiveSupport::TestCase

  fixtures :suburbs, :restaurants, :restaurants_suburbs, :products

  def test_has_and_belongs_to_many
    @restaurant = Restaurant.find([1,1])
    assert_equal 2, @restaurant.suburbs.size

    @restaurant = Restaurant.find([1,1], :include => :suburbs)
    assert_equal 2, @restaurant.suburbs.size
  end

  def test_include_cpk_both_sides
    # assuming the association was set up in the fixtures
    # file restaurants_suburbs.yml
    mcdonalds = restaurants(:mcdonalds)
    suburb = mcdonalds.suburbs[0]
    assert mcdonalds.suburbs.include?(suburb)
  end

  def test_include_cpk_owner_side_only
    subway = restaurants(:subway_one)
    product = products(:first_product)
    subway.products << product
    # reload 
    subway = restaurants(:subway_one)
    assert subway.products.include?(product)
  end

  def test_include_cpk_association_side_only
    product = products(:first_product)
    subway = restaurants(:subway_one)
    product.restaurants << subway
    # reload
    product = products(:first_product)
    assert product.restaurants.include?(subway)
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
    # reload to force reload of associations
    subway = restaurants(:subway_one)
    assert_equal 0, subway.products.size
  end

  def test_habtm_clear_cpk_association_side_only
    product = products(:first_product)
    subway_one = restaurants(:subway_one)
    subway_two = restaurants(:subway_two)
    product.restaurants << subway_one << subway_two
    assert_equal 2, product.restaurants.size
    product.restaurants.clear
    # reload to force reload of associations
    product = products(:first_product)
    assert_equal 0, product.restaurants.size
  end

  # tests case reported in issue #39 where a bug resulted in
  # deletion of incorrect join table records because the owner's id
  # was assumed to be an array and is not in this case
  # and evaluates to a useable but incorrect value
  def test_habtm_clear_cpk_association_side_only_deletes_only_correct_records
    product_one = Product.find(1)
    product_three = Product.find(3)
    subway_one = restaurants(:subway_one)
    subway_two = restaurants(:subway_two)
    product_one.restaurants << subway_one << subway_two
    product_three.restaurants << subway_one << subway_two
    assert_equal 2, product_one.restaurants.size
    assert_equal 2, product_three.restaurants.size

    # if product_three's id is incorrectly assumed to be
    # an array it will be evaluated as 3[0], which is 1, which would
    # delete product_one's associations rather than product_three's
    product_three.restaurants.clear
    
    # reload to force reload of associations
    product_one = Product.find(1)
    product_three = Product.find(3)
    
    assert_equal 0, product_three.restaurants.size
    assert_equal 2, product_one.restaurants.size
  end

end
