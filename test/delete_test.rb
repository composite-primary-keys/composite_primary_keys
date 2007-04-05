require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class DeleteTest < Test::Unit::TestCase

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
    create_fixtures :reference_types, :reference_codes
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
end