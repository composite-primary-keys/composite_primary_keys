require 'abstract_unit'
require 'fixtures/reference_code'
require 'fixtures/reference_type'

class TestAttributeMethods < Test::Unit::TestCase
  fixtures :reference_codes, :reference_types
  
  def test_read_attribute_with_single_key
    rt = ReferenceType.find(1)
    assert_equal(1, rt.reference_type_id)
    assert_equal('NAME_PREFIX', rt.type_label)
    assert_equal('Name Prefix', rt.abbreviation)
  end

  def test_read_attribute_with_composite_keys
    rc = ReferenceCode.find(1,2)
    assert_equal(1, rc.reference_type_id)
    assert_equal(2, rc.reference_code)
    assert_equal('MRS', rc.code_label)
    assert_equal('Mrs', rc.abbreviation)
  end
end