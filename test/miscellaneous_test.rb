require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class MiscellaneousTest < Test::Unit::TestCase

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
  
  def test_primary_keys
    testing_with do
      if composite?
        assert_not_nil @klass.primary_keys
        assert_equal @primary_keys, @klass.primary_keys
        assert_equal @klass.primary_keys, @klass.primary_key
      else
        assert_not_nil @klass.primary_key
        assert_equal @primary_keys, [@klass.primary_key.to_sym]
      end
      assert_equal @primary_keys.join(','), @klass.primary_key.to_s
      # Need a :primary_keys should be Array with to_s overridden
    end
  end
end