require './abstract_unit'

class TestAttributes < ActiveSupport::TestCase
  fixtures :reference_types, :reference_codes, :products, :tariffs, :product_tariffs
  
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
  
  def test_brackets
    testing_with do
      @first.attributes.each_pair do |attr_name, value|
        assert_equal value, @first[attr_name]
      end
    end
  end

  def test_brackets_primary_key
    testing_with do
      assert_equal(@first.id, @first[@primary_keys])
      assert_equal(@first.id, @first[@first.class.primary_key])
    end
  end

  def test_brackets_assignment
    testing_with do
      @first.attributes.each_pair do |attr_name, value|
        @first[attr_name]= !value.nil? ? value * 2 : '1'
        assert_equal !value.nil? ? value * 2 : '1', @first[attr_name]
      end
    end
  end
    
  def test_brackets_foreign_key_assignment
    flat = tariffs(:flat)
    second_free = tariffs(:free)
    second_free_fk = [:tariff_id, :tariff_start_date]

    second_free[key = second_free_fk] = flat.id
    compare_indexes(flat, flat.class.primary_key, second_free, second_free_fk)
    assert_equal flat.id, second_free[key]

    second_free[key = second_free_fk.to_composite_keys] = flat.id
    assert_equal flat.id, second_free[key]
    compare_indexes(flat, flat.class.primary_key, second_free, second_free_fk)

    second_free[key = second_free_fk.to_composite_keys.to_s] = flat.id
    assert_equal flat.id, second_free[key]
    compare_indexes(flat, flat.class.primary_key, second_free, second_free_fk)
  end
  
  private

  def compare_indexes(obj1, indexes1, obj2, indexes2)
    indexes1.length.times do |key_index|
      assert_equal(obj1[indexes1[key_index].to_s], obj2[indexes2[key_index].to_s])
    end
  end
end