require File.expand_path('../abstract_unit', __FILE__)

class CompositeArraysTest < ActiveSupport::TestCase

  def test_new_primary_keys
    keys = CompositePrimaryKeys::CompositeKeys.new
    assert_not_nil keys
    assert_equal '', keys.to_s
    assert_equal '', "#{keys}"
  end

  def test_initialize_primary_keys
    keys = CompositePrimaryKeys::CompositeKeys.new([1,2,3])
    assert_not_nil keys
    assert_equal '1,2,3', keys.to_s
    assert_equal '1,2,3', "#{keys}"
  end

  def test_to_composite_keys
    keys = [1,2,3].to_composite_keys
    assert_equal CompositePrimaryKeys::CompositeKeys, keys.class
    assert_equal '1,2,3', keys.to_s
  end

  def test_composite_keys_equality
    keys_array_1 = [1, Time.now].to_composite_keys
    keys_array_2 = [1, Time.now].to_composite_keys
    assert keys_array_1 == keys_array_2
    assert keys_array_1.eql? keys_array_2
  end
end