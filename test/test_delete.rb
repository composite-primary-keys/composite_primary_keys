require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'
require 'fixtures/department'
require 'fixtures/employee'

class TestDelete < Test::Unit::TestCase
  fixtures :reference_types, :reference_codes, :departments, :employees
  
  CLASSES = {
    :single => {
      :class => ReferenceType,
      :primary_keys => :reference_type_id,
    },
    :dual   => { 
      :class => ReferenceCode,
      :primary_keys => [:reference_type_id, :reference_code],
    },
  }
  
  def setup
    self.class.classes = CLASSES
  end
  
  def test_destroy_one
    testing_with do
      #assert @first.destroy
      assert true
    end
  end
  
  def test_destroy_one_via_class
    testing_with do
      assert @klass.destroy(*@first.id)
    end
  end
  
  def test_destroy_one_alone_via_class
    testing_with do
      assert @klass.destroy(@first.id)
    end
  end
  
  def test_delete_one
    testing_with do
      assert @klass.delete(*@first.id) if composite?
    end
  end
  
  def test_delete_one_alone
    testing_with do
      assert @klass.delete(@first.id)
    end
  end
  
  def test_delete_many
    testing_with do
      to_delete = @klass.find(:all)[0..1]
      assert_equal 2, to_delete.length
    end
  end
  
  def test_delete_all
    testing_with do
      @klass.delete_all
    end
  end
  
  def test_clear_association
      department = Department.find(1,1)
      assert_equal 2, department.employees.size, "Employee count for department should be 2 before clear"
      department.employees.clear
      assert_equal 0, department.employees.size, "After clear size should 0"
      department.reload
      assert_equal 0, department.employees.size, "After clear count in database should have been 0"
  end
  
  def test_delete_association
      department = Department.find(1,1)
      assert_equal 2, department.employees.size , "Employee count for department should be 2 before delete"
	    first_employee = department.employees[0]
      department.employees.delete(first_employee) 
      assert_equal 1, department.employees.size, "After delete employees count should be 1."
      department.reload
      assert_equal 1, department.employees.size, "After delete employees count should be 1 after reload from DB."
  end
end
