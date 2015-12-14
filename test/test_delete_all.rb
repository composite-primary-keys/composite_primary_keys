require File.expand_path('../abstract_unit', __FILE__)

class EmployeesGroup < ActiveRecord::Base
  
end

class TestValidations < ActiveSupport::TestCase
  fixtures :employees

  def test_delete_for_model_without_primary_key
    EmployeesGroup.create(employee_id: 1, group_id: 100)
    EmployeesGroup.create(employee_id: 2, group_id: 102)
    EmployeesGroup.create(employee_id: 3, group_id: 103)

    assert_equal(EmployeesGroup.all.size, 3)
    assert_raises(ActiveRecord::StatementInvalid) {
      EmployeesGroup.where(employee_id: 1).first.destroy
    }
    assert(EmployeesGroup.all.size == 3)
  end

  # This test fails, requires fixin arel
  def test_delete_all_with_joins
    ReferenceCode.joins(:reference_type).where(:reference_type_id => 1).delete_all
  end
end
