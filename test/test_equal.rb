require File.expand_path('../abstract_unit', __FILE__)

class TestEqual < ActiveSupport::TestCase
  fixtures :restaurants, :products

  ############################################################
  ### Tests for Product model with single primary key (id) ###
  ############################################################

  def test_single_same
    first = Product.find(1)
    second = Product.find(1)
    assert_equal(first, second)
  end

  def test_different
    first = Product.find(1)
    second = Product.find(2)
    assert_not_equal(first, second)
  end

  def test_two_new_objects_are_not_equal
    assert_not_equal(Product.new, Product.new)
  end

  def test_same_new_object_is_equal_to_itself
    it = Product.new
    assert_equal(it, it)
  end

  #####################################################################################
  ### Tests for Restaurant model with composite primary key (franchise_id, store_id) ##
  #####################################################################################

  def test_composite_same
    first = Restaurant.find([1, 1])
    second = Restaurant.find([1, 1])
    assert_equal(first, second)
  end

  def test_composite_different
    first = Restaurant.find([1, 1])
    second = Restaurant.find([2, 2])
    assert_not_equal(first, second)
  end

  def test_composite_two_new_objects_are_not_equal
    assert_not_equal(Restaurant.new, Restaurant.new)
  end

  def test_composite_same_new_object_is_equal_to_itself
    it = Restaurant.new
    assert_equal(it, it)
  end
end
