require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class PrimaryKeyTest < Test::Unit::TestCase

  def test_new
    keys = CompositePrimaryKeys::PrimaryKeys.new
    assert_not_nil keys
    assert_equal '', keys.to_s
    assert_equal '', "#{keys}"
  end

  def test_initialize
    keys = CompositePrimaryKeys::PrimaryKeys.new([1,2,3])
    assert_not_nil keys
    assert_equal '1,2,3', keys.to_s
    assert_equal '1,2,3', "#{keys}"
  end
end