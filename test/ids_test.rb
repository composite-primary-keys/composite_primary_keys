require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class IdsTest < Test::Unit::TestCase
  
  def test_ids
    testing_with do
      assert_equal @first.id, @first.ids if composite?
    end
  end
end