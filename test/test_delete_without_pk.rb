require File.expand_path('../abstract_unit', __FILE__)

class TestDeleteWithoutPK < ActiveSupport::TestCase

  # can't load fixtures because other test dependencies
  setup do
    EmployeesGroup.create(employee_id: 1, group_id: 1)
    EmployeesGroup.create(employee_id: 1, group_id: 2)
    EmployeesGroup.create(employee_id: 2, group_id: 1)
    EmployeesGroup.create(employee_id: 2, group_id: 1)
  end

  def test_destroy_without_primary_key
    employees_group = EmployeesGroup.first
    assert_raise(ActiveRecord::CompositeKeyError) do
      employees_group.destroy
    end
    assert_equal 4, EmployeesGroup.count
  end
end
