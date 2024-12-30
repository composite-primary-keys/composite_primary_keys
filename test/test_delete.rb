require File.expand_path('../abstract_unit', __FILE__)

class TestDelete < ActiveSupport::TestCase
  fixtures :articles, :departments, :employees, :products, :tariffs, :product_tariffs,
           :reference_types, :reference_codes

  def test_delete_one
    assert_equal(5, ReferenceCode.count)
    ReferenceCode.first.delete
    assert_equal(4, ReferenceCode.count)
  end

  def test_delete_one_with_id
    assert_equal(5, ReferenceCode.count)
    deleted = ReferenceCode.delete(ReferenceCode.first.id)
    assert_equal(4, ReferenceCode.count)
    assert_equal(1, deleted)
  end

  def test_destroy_one
    assert_equal(5, ReferenceCode.count)
    ReferenceCode.first.destroy
    assert_equal(4, ReferenceCode.count)
  end

  def test_delete_all
    refute_empty(ReferenceCode.all)
    deleted = ReferenceCode.delete_all
    assert_empty(ReferenceCode.all)
    assert_equal(5, deleted)
  end

  def test_delete_all_default_order
    refute_empty(Tariff.all)
    deleted = Tariff.delete_all
    assert_empty(Tariff.all)
    assert_equal(3, deleted)
  end

  def test_delete_all_with_join
    tested_delete_all = false
    Arel::Table.engine = nil # should not rely on the global Arel::Table.engine
    employee = employees(:mindy)

    assert_equal(5, Department.count)

    deleted = Department.joins(:employees).
                         where('employees.name = ?', employee.name).
                         delete_all

    assert_equal(4, Department.count)
    assert_equal(1, deleted)
    tested_delete_all = true
  ensure
    Arel::Table.engine = ActiveRecord::Base
    assert tested_delete_all
  end

  def test_clear_association
    department = Department.find([1,1])
    assert_equal(2, department.employees.size, "Before clear employee count should be 2.")

    department.employees.clear
    assert_equal(0, department.employees.size, "After clear employee count should be 0.")

    department.reload
    assert_equal(0, department.employees.size, "After clear and a reload from DB employee count should be 0.")
  end

  def test_delete_association
    department = Department.find([1,1])
    assert_equal 2, department.employees.size , "Before delete employee count should be 2."
    first_employee = department.employees[0]
    department.employees.delete(first_employee)
    assert_equal 1, department.employees.size, "After delete employee count should be 1."
    department.reload
    assert_equal 1, department.employees.size, "After delete and a reload from DB employee count should be 1."
  end

  def test_has_many_replace
    tariff = tariffs(:flat)
    assert_equal(1, tariff.product_tariffs.length)

    tariff.product_tariffs = [product_tariffs(:first_free), product_tariffs(:second_free)]
    tariff.reload

    assert_equal(2, tariff.product_tariffs.length)
    refute(tariff.product_tariffs.include?(tariff))
  end

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
    records_before = ActiveRecord::Base.connection.execute('select * from employees_groups')
    steve.destroy
    records_after = ActiveRecord::Base.connection.execute('select * from employees_groups')
    if records_before.respond_to?(:count)
      assert_equal records_after.count, records_before.count - steve.groups.count
    elsif records_before.respond_to?(:row_count) # OCI8:Cursor for oracle adapter
      assert_equal records_after.row_count, records_before.row_count - steve.groups.count
    end
  end

  def test_create_destroy_has_and_belongs_to_many_on_non_cpk
    records_before = ActiveRecord::Base.connection.execute('select * from employees_groups')
    employee = Employee.create!(department_id: 3, location_id: 2, name: 'Jon')
    employee.groups << Group.create(name: 'test')
    employee.destroy!
    records_after = ActiveRecord::Base.connection.execute('select * from employees_groups')
    if records_before.respond_to?(:count)
      assert_equal records_before.count, records_after.count
    elsif records_before.respond_to?(:row_count) # OCI8:Cursor for oracle adapter
      assert_equal records_before.row_count, records_after.row_count
    end
  end

  def test_create_destroy_all_has_and_belongs_to_many_on_non_cpk
    records_before = ActiveRecord::Base.connection.execute('select * from employees_groups')
    employee = Employee.create!(department_id: 3, location_id: 2, name: 'Jon')
    employee.groups << Group.create(name: 'test')
    employee.groups.destroy_all
    records_after = ActiveRecord::Base.connection.execute('select * from employees_groups')
    if records_before.respond_to?(:count)
      assert_equal records_before.count, records_after.count
    elsif records_before.respond_to?(:row_count) # OCI8:Cursor for oracle adapter
      assert_equal records_before.row_count, records_after.row_count
    end
  end

  def test_delete_not_destroy_on_cpk
    tariff = Tariff.where(tariff_id: 2).first
    tariff.delete
    refute(tariff.persisted?)
  end

  def test_delete_not_destroy_on_non_cpk
    article = articles(:third)
    article.delete
    refute(article.persisted?)
  end

  def test_destroy_has_many_delete_all
    # In this case the association is a has_many composite key with
    # dependent set to :delete_all
    product = Product.find(1)
    assert_equal(2, product.product_tariffs.length)

    # Get product_tariff length
    product_tariff_size = ProductTariff.count

    # Delete product - should delete 2 product tariffs
    product.destroy

    # Verify product_tariff are deleted
    assert_equal(product_tariff_size - 2, ProductTariff.count)
  end

  def test_delete_cpk_association
    product = Product.find(1)
    assert_equal(2, product.product_tariffs.length)

    product_tariff = product.product_tariffs.first
    product.product_tariffs.delete(product_tariff)

    product.reload
    assert_equal(1, product.product_tariffs.length)
  end

  def test_delete_records_for_has_many_association_with_composite_primary_key
    reference_type  = ReferenceType.find(1)
    codes_to_delete = reference_type.reference_codes[0..1]
    assert_equal(3, reference_type.reference_codes.size, "Before deleting records reference_code count should be 3.")

    reference_type.reference_codes.delete(codes_to_delete)
    reference_type.reload
    assert_equal(1, reference_type.reference_codes.size, "After deleting 2 records and a reload from DB reference_code count should be 1.")
  end
end
