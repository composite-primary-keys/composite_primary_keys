require File.expand_path('../abstract_unit', __FILE__)

class TestForeignKeyId < ActiveSupport::TestCase
  fixtures :items, :item_attribs

  # TODO remove later
  def test_basic_count_and_find
    assert_equal(4, Item.count)
    assert_equal(4, ItemAttrib.count)

    assert_kind_of(Item, Item.find([11111, 10]))
    assert_kind_of(Item, Item.find([11111, 11]))
    assert_kind_of(Item, Item.find([22222, 20]))
    assert_kind_of(Item, Item.find([22222, 21]))
    assert_raise(ActiveRecord::RecordNotFound) { Item.find([99999, 10]) }

    assert_kind_of(ItemAttrib, ItemAttrib.find(1))
    assert_kind_of(ItemAttrib, ItemAttrib.find(2))
    assert_kind_of(ItemAttrib, ItemAttrib.find(3))
    assert_kind_of(ItemAttrib, ItemAttrib.find(4))
    assert_raise(ActiveRecord::RecordNotFound) { ItemAttrib.find(5) }
  end

  def test_read_id
    item = Item.find([11111, 10])

    assert_equal([11111, 10], item.id)
    assert_equal(1, item[:id])
    assert_equal(1, item['id'])
    assert_equal(1, item.read_attribute(:id))
    assert_equal(1, item.read_attribute('id'))
  end

  def test_item_attribs_association
    item = Item.find([11111, 10])
    item_attribs = item.item_attribs

    assert_kind_of(ActiveRecord::Associations::CollectionProxy, item_attribs)
    assert_equal(2, item_attribs.count)
    assert_equal(ItemAttrib.find(1), item_attribs[0])
    assert_equal(ItemAttrib.find(2), item_attribs[1])
  end

  def test_item_association
    item_attrib = ItemAttrib.find(1)
    item = item_attrib.item

    assert_kind_of(Item, item)
    assert_equal(Item.find([11111, 10]), item)
  end

  def test_item_attribs_association_with_includes
    item = Item.includes(:item_attribs).find([11111, 10])
    item_attribs = item.item_attribs
    assert(item_attribs.loaded?)
    assert_equal(2, item_attribs.count)
  end

  def test_item_association_without_includes
    item = Item.find([11111, 10])
    item_attribs = item.item_attribs
    assert_not(item_attribs.loaded?)
    assert_equal(2, item_attribs.count)
  end
end
