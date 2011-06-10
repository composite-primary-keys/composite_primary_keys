require 'abstract_unit'

class TestAttributeMethods < ActiveSupport::TestCase
  fixtures :reference_types
  
  def test_read_attribute_with_single_key
    rt = ReferenceType.find(1)
    assert_equal(1, rt.reference_type_id)
    assert_equal('NAME_PREFIX', rt.type_label)
    assert_equal('Name Prefix', rt.abbreviation)
  end

  def test_read_attribute_with_composite_keys
    ref_code = ReferenceCode.find(1,1)
    assert_equal(1, ref_code.id.first)
    assert_equal(1, ref_code.id.last)
    assert_equal('Mr', ref_code.abbreviation)
  end
end
