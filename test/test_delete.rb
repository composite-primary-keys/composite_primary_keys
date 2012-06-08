require File.expand_path('../abstract_unit', __FILE__)

class TestDelete < ActiveSupport::TestCase
  fixtures :departments, :employees, :products, :product_tariffs,
           :reference_types, :reference_codes
  
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
  
#  def test_destroy_one
#    testing_with do
#      assert @first.destroy
#    end
#  end
#
#  def test_destroy_one_alone_via_class
#    testing_with do
#      assert @klass.destroy(@first.id)
#    end
#  end
#
#  def test_delete_one_alone
#    testing_with do
#      assert @klass.delete(@first.id)
#    end
#  end
#
#  def test_delete_many
#    testing_with do
#      to_delete = @klass.find(:all)[0..1]
#      assert_equal 2, to_delete.length
#    end
#  end
#
#  def test_delete_all
#    testing_with do
#      @klass.delete_all
#    end
#  end
#
#  def test_clear_association
#    department = Department.find(1,1)
#    assert_equal(2, department.employees.size, "Before clear employee count should be 2.")
#
#    department.employees.clear
#    assert_equal(0, department.employees.size, "After clear employee count should be 0.")
#
#    department.reload
#    assert_equal(0, department.employees.size, "After clear and a reload from DB employee count should be 0.")
#  end
#
#  def test_delete_association
#    department = Department.find(1,1)
#    assert_equal 2, department.employees.size , "Before delete employee count should be 2."
#    first_employee = department.employees[0]
#    department.employees.delete(first_employee)
#    assert_equal 1, department.employees.size, "After delete employee count should be 1."
#    department.reload
#    assert_equal 1, department.employees.size, "After delete and a reload from DB employee count should be 1."
#  end

  def test_destroy_has_one
    # In this case the association is a has_one with
    # dependent set to :destroy
    department = departments(:engineering)
    assert_not_nil(department.head)

    # Get head employee id
    head_id = department.head.id

    # Delete department - should delete the head
    department.destroy

    # Verify the head is also
    assert_raise(ActiveRecord::RecordNotFound) do
      Employee.find(head_id)
    end
  end
  
  def test_destroy_has_and_belongs_to_many_on_non_cpk
    steve = employees(:steve)
    records_before = ActiveRecord::Base.connection.execute("select * from employees_groups").count
    steve.destroy
    records_after = ActiveRecord::Base.connection.execute("select * from employees_groups").count
    assert_equal records_after, records_before - steve.groups.count
  end

#  def test_destroy_has_many_delete_all
#    # In this case the association is a has_many composite key with
#    # dependent set to :delete_all
#    product = Product.find(1)
#    assert_equal(2, product.product_tariffs.length)
#
#    # Get product_tariff length
#    product_tariff_size = ProductTariff.count
#
#    # Delete product - should delete 2 product tariffs
#    product.destroy
#
#    # Verify product_tariff are deleted
#    assert_equal(product_tariff_size - 2, ProductTariff.count)
#  end
#
#  def test_delete_cpk_association
#    product = Product.find(1)
#    assert_equal(2, product.product_tariffs.length)
#
#    product_tariff = product.product_tariffs.first
#    product.product_tariffs.delete(product_tariff)
#
#    product.reload
#    assert_equal(1, product.product_tariffs.length)
#  end
#
#  def test_delete_records_for_has_many_association_with_composite_primary_key
#    reference_type  = ReferenceType.find(1)
#    codes_to_delete = reference_type.reference_codes[0..1]
#    assert_equal(3, reference_type.reference_codes.size, "Before deleting records reference_code count should be 3.")
#
#    reference_type.reference_codes.delete(codes_to_delete)
#    reference_type.reload
#    assert_equal(1, reference_type.reference_codes.size, "After deleting 2 records and a reload from DB reference_code count should be 1.")
#  end
end
