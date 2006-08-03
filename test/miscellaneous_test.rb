require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class MiscellaneousTest < Test::Unit::TestCase
  fixtures :reference_types, :reference_codes
  
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
    super
    self.class.classes = CLASSES
  end

  def test_composite_class
    testing_with do
      assert_equal composite?, @klass.composite?
    end
  end

  def test_composite_instance
    testing_with do
      assert_equal composite?, @first.composite?
    end
  end
  
  def test_count
    assert_equal 2, Product.count
  end
  
end