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

  def test_parse
    assert_equal ['1', '2'], CompositePrimaryKeys::CompositeKeys.parse('1,2')
    assert_equal ['The USA', '^Washington, D.C.'],
                 CompositePrimaryKeys::CompositeKeys.parse('The USA,^5EWashington^2C D.C.')
    assert_equal ['The USA', '^Washington, D.C.'],
                 CompositePrimaryKeys::CompositeKeys.parse(['The USA', '^Washington, D.C.'])
  end

  def test_to_s
    assert_equal '1,2', CompositePrimaryKeys::CompositeKeys.new([1, 2]).to_s
    assert_equal 'The USA,^5EWashington^2C D.C.',
                 CompositePrimaryKeys::CompositeKeys.new(['The USA', '^Washington, D.C.']).to_s
  end

  def test_to_param
    assert_equal '1,2', CompositePrimaryKeys::CompositeKeys.new([1, 2]).to_param
    assert_equal 'The USA,^5EWashington^2C D.C.',
                 CompositePrimaryKeys::CompositeKeys.new(['The USA', '^Washington, D.C.']).to_param
  end
end
