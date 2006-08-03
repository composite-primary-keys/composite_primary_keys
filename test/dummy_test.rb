require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class DummyTest < Test::Unit::TestCase
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
  
  def test_truth
    testing_with do
      assert true
    end
  end
end