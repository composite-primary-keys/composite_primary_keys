require File.expand_path('../abstract_unit', __FILE__)

# Testing the find action on composite ActiveRecords with two primary keys
class TestFind < ActiveSupport::TestCase
  fixtures :capitols, :departments, :reference_types, :reference_codes, :suburbs

  def test_find_first
    ref_code = ReferenceCode.order('reference_type_id, reference_code').first
    assert_kind_of(ReferenceCode, ref_code)
    assert_equal([1,1], ref_code.id)
  end

  def test_find_last
    ref_code = ReferenceCode.order('reference_type_id, reference_code').last
    assert_kind_of(ReferenceCode, ref_code)
    assert_equal([2,2], ref_code.id)
  end

  def test_find_one
    ref_code = ReferenceCode.find([1,3])
    assert_not_nil(ref_code)
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

  def test_find_each
    room_assignments = []
    RoomAssignment.find_each(:batch_size => 2) do |assignment|
      room_assignments << assignment
    end

    assert_equal(RoomAssignment.count, room_assignments.uniq.length)
  end

  def test_find_each_with_scope
    scoped_departments = Department.where("department_id <> 3")
    scoped_departments.find_each(:batch_size => 2) do |department|
      assert department.id != 3
    end
  end

  def test_not_found
    error = assert_raise(::ActiveRecord::RecordNotFound) do
      ReferenceCode.find(['999', '999'])
    end

    connection = ActiveRecord::Base.connection
    ref_type_quoted = "#{connection.quote_table_name('reference_codes')}.#{connection.quote_column_name('reference_type_id')}"
    ref_code_quoted = "#{connection.quote_table_name('reference_codes')}.#{connection.quote_column_name('reference_code')}"

    expected = "Couldn't find all ReferenceCodes with 'reference_type_id,reference_code': (999, 999) (found 0 results, but was looking for 1)"
    assert_equal(with_quoted_identifiers(expected), error.message)
  end

  def test_find_last_suburb
    suburb = Suburb.last
    assert_equal([2,1], suburb.id)
  end

  def test_find_last_suburb_with_order
    # Rails actually changes city_id DESC to city_id ASC
    suburb = Suburb.order('suburbs.city_id DESC').last
    assert_equal([1,1], suburb.id)
  end

  def test_find_in_batches
    Department.find_in_batches do |batch|
      assert_equal(Department.count, batch.size)
    end
  end

  def test_expand
    department = departments(:engineering)
    employees = Employee.where(:department => department)
    assert_equal(2, employees.count)
  end

  def test_find_one_with_params_id
    params_id = ReferenceCode.find([1,3]).to_param
    assert_equal params_id, "1,3"

    ref_code = ReferenceCode.find(params_id)
    assert_not_nil(ref_code)
    assert_equal([1,3], ref_code.id)
  end

  def test_find_some_with_array_of_params_id
    params_ids = ReferenceCode.find([1,3], [2,1]).map(&:to_param)
    assert_equal ["1,3", "2,1"], params_ids

    ref_codes = ReferenceCode.find(params_ids)
    assert_kind_of(Array, ref_codes)
    assert_equal(2, ref_codes.length)

    ref_code = ref_codes[0]
    assert_equal([1,3], ref_code.id)

    ref_code = ref_codes[1]
    assert_equal([2,1], ref_code.id)
  end

  fixtures :mittens

  def test_find_one_with_nil_as_part_of_id
    fully_defined = mittens(:red_pair)
    assert_equal("1,2", fully_defined.to_param)

    somewhat_lacking = mittens(:blue_pair)
    assert_equal(",3", somewhat_lacking.to_param)
    assert_equal([nil, 3], somewhat_lacking.to_key)

    assert_equal('The red ones', Mitten.find([1,2]).name)
    assert_equal('The blue ones', Mitten.find([nil, 3]).name)
  end
end
