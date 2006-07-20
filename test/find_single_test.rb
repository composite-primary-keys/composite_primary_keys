require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

# Testing the find action on normal ActiveRecords
class FindSingleTest < Test::Unit::TestCase
  fixtures :reference_types, :reference_codes
  
  CLASS = ReferenceType
  PRIMARY_KEYS = [:reference_type_id]
  
  def setup
    @first = CLASS.find_first
  end
  
  def test_primary_keys
    assert_equal PRIMARY_KEYS, [CLASS.primary_key.to_sym]
  end
  
  def test_find_first
    obj = CLASS.find_first
    assert obj
    assert_equal CLASS, obj.class
  end

  def test_find
    found = CLASS.find(*first_id)
    assert found
    assert_equal CLASS, found.class
    assert_equal found, CLASS.find(found.id.to_s)
    assert_equal found, CLASS.find(found.to_param)
  end
  
  def test_to_param
    assert_equal first_id_str, @first.to_param.to_s
  end
  
private
  def first_id
    (1..PRIMARY_KEYS.length).map {|num| 1}
  end
  
  def first_id_str
    first_id.join(',')
  end
end