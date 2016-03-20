require File.expand_path('../abstract_unit', __FILE__)

class TestForeignKeyId < ActiveSupport::TestCase
  fixtures :items, :item_infos

  def test_has_one_item_info
    item = Item.find([11111, 10])
    assert_equal(ItemInfo.find(1), item.item_info)
  end

  def test_belongs_to_item
    item_info = ItemInfo.find(1)
    assert_equal(Item.find([11111, 10]), item_info.item)
  end

end