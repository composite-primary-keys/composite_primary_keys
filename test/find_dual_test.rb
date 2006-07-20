require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

# Testing the find action on composite ActiveRecords with two primary keys
class FindDualTest < Test::Unit::TestCase
  fixtures :reference_types, :reference_codes
  
  CLASS = ReferenceCode
  PRIMARY_KEYS = [:reference_type_id, :reference_code]
  
  def setup
    @first = CLASS.find_first
  end
  
  def test_primary_keys
    assert_equal PRIMARY_KEYS, CLASS.primary_keys
  end
  
  def test_find_first
    obj = CLASS.find_first
    assert obj
    assert_equal CLASS, obj.class
  end

  def test_find
    found = CLASS.find(*first_id) # e.g. find(1,1) or find 1,1
    assert found
    assert_equal CLASS, found.class
    assert_equal found, CLASS.find(found.id)
    assert_equal found, CLASS.find(found.to_param)
  end
  
  def test_to_param
    assert_equal first_id_str, @first.to_param.to_s
  end
  
  def things_to_look_at
    assert_equal found, CLASS.find(found.id.to_s) # fails for 2+ keys
  end
private
  def first_id
    (1..PRIMARY_KEYS.length).map {|num| 1}
  end
  
  def first_id_str
    first_id.join(',')
  end
end