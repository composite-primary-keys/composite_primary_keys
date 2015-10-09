require File.expand_path('../abstract_unit', __FILE__)

class TestHasAndBelongsToManyIds < ActiveSupport::TestCase
  fixtures :items, :item_groups

  def test_habtm_items_insert
    i1 = Item.find([11111, 10])
    i2 = Item.find([11111, 11])

    ig1 = ItemGroup.find([1, 'one'])
    ig2 = ItemGroup.find([2, 'two'])

    ig1.items << i1
    ig1.items << i2
    ig2.items << i2

    i1.reload
    i2.reload

    ig1.reload
    ig2.reload

    assert_equal(2, ig1.items.count)
    assert_equal(i1, ig1.items[0])
    assert_equal(i2, ig1.items[1])

    assert_equal(1, ig2.items.count)
    assert_equal(i2, ig2.items[0])

    assert_equal(1, i1.item_groups.count)
    assert_equal(ig1, i1.item_groups[0])

    assert_equal(2, i2.item_groups.count)
    assert_equal(ig1, i2.item_groups[0])
    assert_equal(ig2, i2.item_groups[1])
  end

  def test_habtm_item_groups_insert
    i1 = Item.find([11111, 10])
    i2 = Item.find([11111, 11])

    ig1 = ItemGroup.find([1, 'one'])
    ig2 = ItemGroup.find([2, 'two'])

    i1.item_groups << ig1
    i1.item_groups << ig2
    i2.item_groups << ig2

    i1.reload
    i2.reload

    ig1.reload
    ig2.reload

    assert_equal(2, i1.item_groups.count)
    assert_equal(ig1, i1.item_groups[0])
    assert_equal(ig2, i1.item_groups[1])

    assert_equal(1, i2.item_groups.count)
    assert_equal(ig2, i2.item_groups[0])

    assert_equal(1, ig1.items.count)
    assert_equal(i1, ig1.items[0])

    assert_equal(2, ig2.items.count)
    assert_equal(i1, ig2.items[0])
    assert_equal(i2, ig2.items[1])
  end
end

