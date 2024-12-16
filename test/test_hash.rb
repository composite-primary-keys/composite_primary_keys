require File.expand_path('../abstract_unit', __FILE__)

class TestHash < ActiveSupport::TestCase
  fixtures :restaurants, :products

  ############################################################
  ### Tests for Product model with single primary key (id) ###
  ############################################################

  def test_single_same_object_has_the_same_hash
    first = Product.find(1)
    second = Product.find(1)
    assert_equal(first.hash, second.hash)
  end

  def test_single_different_objects_have_different_hashes
    first = Product.find(1)
    second = Product.find(2)
    assert_not_equal(first.hash, second.hash)
  end

  def test_single_persisted_object_hash_is_based_on_primary_key
    first = Product.find(1)
    second = Product.find(1)

    assert_equal(first.hash, second.hash)
    first.name = 'new name'
    assert_equal(first.hash, second.hash)
  end

  def test_single_two_new_objects_have_different_hashes
    assert_not_equal(Product.new.hash, Product.new.hash)
  end

  def test_single_same_new_object_has_the_same_hash
    it = Product.new
    assert_equal(it.hash, it.hash)
  end

  #####################################################################################
  ### Tests for Restaurant model with composite primary key (franchise_id, store_id) ##
  #####################################################################################

  def test_composite_same_object_has_the_same_hash
    first = Restaurant.find([1, 1])
    second = Restaurant.find([1, 1])
    assert_equal(first.hash, second.hash)
  end

  def test_composite_different_objects_have_different_hashes
    first = Restaurant.find([1, 1])
    second = Restaurant.find([2, 2])
    assert_not_equal(first.hash, second.hash)
  end

  def test_composite_persisted_object_hash_is_based_on_primary_key
    first = Restaurant.find([1, 1])
    second = Restaurant.find([1, 1])

    assert_equal(first.hash, second.hash)
    first.name = 'new name'
    assert_equal(first.hash, second.hash)
  end

  def test_composite_two_new_objects_have_different_hashes
    assert_not_equal(Restaurant.new.hash, Restaurant.new.hash)
  end

  def test_composite_same_new_object_has_the_same_hash
    it = Restaurant.new
    assert_equal(it.hash, it.hash)
  end
end
