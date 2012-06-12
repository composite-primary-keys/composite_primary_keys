require File.expand_path('../abstract_unit', __FILE__)

# Testing the find action on composite ActiveRecords with two primary keys
class TestFind < ActiveSupport::TestCase
  fixtures :capitols, :reference_types, :reference_codes, :suburbs

  def test_find_first
    ref_code = ReferenceCode.find(:first, :order => 'reference_type_id, reference_code')
    assert_kind_of(ReferenceCode, ref_code)
    assert_equal([1,1], ref_code.id)
  end

  def test_find_last
    ref_code = ReferenceCode.find(:last, :order => 'reference_type_id, reference_code')
    assert_kind_of(ReferenceCode, ref_code)
    assert_equal([2,2], ref_code.id)
  end

  def test_find_one
    ref_code = ReferenceCode.find([1,3])
    assert_not_nil(ref_code)
    assert_equal([1,3], ref_code.id)
  end

  def test_find_one_string
    ref_code = ReferenceCode.find('1,3')
    assert_kind_of(ReferenceCode, ref_code)
    assert_equal([1,3], ref_code.id)
  end

  def test_find_some
    ref_codes = ReferenceCode.find([1,3], [2,1])
    assert_kind_of(Array, ref_codes)
    assert_equal(2, ref_codes.length)

    ref_code = ref_codes[0]
    assert_equal([1,3], ref_code.id)

    ref_code = ref_codes[1]
    assert_equal([2,1], ref_code.id)
  end

  def test_find_with_strings_as_composite_keys
    capitol = Capitol.find(['The Netherlands', 'Amsterdam'])
    assert_kind_of(Capitol, capitol)
    assert_equal(['The Netherlands', 'Amsterdam'], capitol.id)
  end

  def test_not_found
    error = assert_raise(::ActiveRecord::RecordNotFound) do
      ReferenceCode.find(['999', '999'])
    end

    connection = ActiveRecord::Base.connection
    ref_type_quoted = "#{connection.quote_table_name('reference_codes')}.#{connection.quote_column_name('reference_type_id')}"
    ref_code_quoted = "#{connection.quote_table_name('reference_codes')}.#{connection.quote_column_name('reference_code')}"

    if current_adapter?(:SQLServerAdapter)
      expected = "Couldn't find ReferenceCode with ID=999,999 WHERE #{ref_type_quoted} = N'999' AND #{ref_code_quoted} = N'999'"
    else
      expected = "Couldn't find ReferenceCode with ID=999,999 WHERE #{ref_type_quoted} = 999 AND #{ref_code_quoted} = 999"
    end

    assert_equal(with_quoted_identifiers(expected),
                 error.message)
  end

  def test_find_last_suburb
    suburb = Suburb.find(:last)
    assert_equal([2,1], suburb.id)
  end

  def test_find_last_suburb_with_order
    # Rails actually changes city_id DESC to city_id ASC
    suburb = Suburb.find(:last, :order => 'suburbs.city_id DESC')
    assert_equal([1,1], suburb.id)
  end
end