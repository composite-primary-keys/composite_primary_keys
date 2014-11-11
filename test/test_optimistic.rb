require File.expand_path('../abstract_unit', __FILE__)

class TestOptimisitic < ActiveSupport::TestCase
  fixtures :boards

  CLASSES = {
    :single => {
      :class => Board,
      :primary_keys => :reference_type_id,
      :update => { :text => 'board aaa' },
    }
  }

  def setup
    self.class.classes = CLASSES
  end

  def test_setup
    testing_with do
      assert_not_nil @klass_info[:update]
    end
  end

  def test_update_attributes
    testing_with do
      assert(@first.update_attributes(@klass_info[:update]))
      assert(@first.reload)
      @klass_info[:update].each_pair do |attr_name, new_value|
        assert_equal(new_value, @first[attr_name])
      end
    end
  end

  def test_update_primary_key
    obj = Board.find([1,1])
    obj.board_id = 2
    obj.board_no = 3
    assert(obj.primary_key_changed?)
    assert_equal({"board_id" => 1, "board_no" => 1}, obj.primary_key_was)
    assert_equal({"board_id" => 2, "board_no" => 3}, obj.ids_hash)
    assert(obj.save)
    assert(obj.reload)
    assert_equal(2, obj.board_id)
    assert_equal(3, obj.board_no)
    assert_equal({"board_id" => 2, "board_no" => 3}, obj.ids_hash)
    assert_equal([2, 3], obj.id)
  end

  def test_update_attribute
    obj = Board.find([1, 1])
    obj[:text] = 'a'
    obj['text'] = 'b'
    assert(obj.save)
    assert(obj.reload)
    assert_equal('b', obj.text)
  end

  def test_update_with_stale_error
    obj1 = Board.find([1, 1])
    obj1['text'] = 'b'

    obj2 = Board.find([1, 1])
    obj2['text'] = 'c'

    assert(obj1.save)
    assert_raise ActiveRecord::StaleObjectError do
      obj2.save
    end
  end
end
