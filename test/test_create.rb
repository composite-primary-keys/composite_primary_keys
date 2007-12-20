require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'

class TestCreate < Test::Unit::TestCase
  fixtures :reference_types, :reference_codes
  
  CLASSES = {
    :single => {
      :class => ReferenceType,
      :primary_keys => :reference_type_id,
      :create => {:reference_type_id => 10, :type_label => 'NEW_TYPE', :abbreviation => 'New Type'}
    },
    :dual   => { 
      :class => ReferenceCode,
      :primary_keys => [:reference_type_id, :reference_code],
      :create => {:reference_type_id => 1, :reference_code => 20, :code_label => 'NEW_CODE', :abbreviation => 'New Code'}
    },
  }
  
  def setup
    self.class.classes = CLASSES
  end
  
  def test_setup
    testing_with do
      assert_not_nil @klass_info[:create]
    end
  end
  
  def test_create
    testing_with do
      assert new_obj = @klass.create(@klass_info[:create])
      assert !new_obj.new_record?
    end
  end
  
  def test_create_no_id
    testing_with do
      begin
        @obj = @klass.create(@klass_info[:create].block(@klass.primary_key))
        @successful = !composite?
      rescue CompositePrimaryKeys::ActiveRecord::CompositeKeyError
        @successful = false
      rescue
        flunk "Incorrect exception raised: #{$!}, #{$!.class}"
      end
      assert_equal composite?, !@successful, "Create should have failed for composites; #{@obj.inspect}"
    end
  end
end