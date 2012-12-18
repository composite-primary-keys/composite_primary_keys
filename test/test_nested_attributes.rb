require File.expand_path('../abstract_unit', __FILE__)

# Testing the find action on composite ActiveRecords with two primary keys
class TestNestedAttributes < ActiveSupport::TestCase
  fixtures :reference_types

  def setup
    @reference_type = ReferenceType.first
  end

  def test_nested_atttribute_create
    code_id = 1001
    @reference_type.update_attribute :reference_codes_attributes, [{
      :reference_code => code_id,
      :code_label => 'XX',
      :abbreviation => 'Xx'
    }]
    assert_not_nil ReferenceCode.find_by_reference_code(code_id)
  end

  def test_nested_atttribute_update
    code_id = 1002
    @reference_type.update_attribute :reference_codes_attributes, [{
      :reference_code => code_id,
      :code_label => 'XX',
      :abbreviation => 'Xx'
    }]
    reference_code = ReferenceCode.find_by_reference_code(code_id)
    cpk = CompositePrimaryKeys::CompositeKeys[@reference_type.reference_type_id, code_id]
    @reference_type.update_attribute :reference_codes_attributes, [{
      :id => cpk,
      :code_label => 'AAA',
      :abbreviation => 'Aaa'
    }]
    reference_code = ReferenceCode.find_by_reference_code(code_id)
    assert_kind_of(ReferenceCode, reference_code)
    assert_equal(reference_code.code_label, 'AAA')
  end
end
