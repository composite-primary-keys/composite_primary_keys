require File.expand_path('../abstract_unit', __FILE__)

class TestHasAndBelongsToManyIds < ActiveSupport::TestCase
  fixtures :items, :item_groups

  def test_basic_stuff
    ig1 = ItemGroup.find([1, 'one'])
    assert_not_nil(ig1)
    assert_equal('first itemgroup', ig1.group_desc)

    it = Item.find([11111, 10])
    ig1.items << it
    ig1.reload

    ig1 = ItemGroup.find([1, 'one'])
    assert_equal(1, ig1.items.count)
    assert_equal(Item.find([11111, 10]), ig1.items[0])
  end

  def test_nunu
    i1 = Item.find([11111, 10])
    assert_not_nil(i1)

    i1.item_groups << ItemGroup.find([1, 'one'])
    i1.reload

    i1 = Item.find([11111, 10])
    assert_equal(1, i1.item_groups.count)
    assert_equal(ItemGroup.find([1, 'one']), i1.item_groups[0])
  end
end

