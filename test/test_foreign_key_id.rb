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

  def test_simple_add_to_association_fires_insert
    item = Item.find([11111, 10])
    itemattribs = ItemAttrib.new(:key => 'test_key', :value => 'test_value')
    assert_equal(2, item.item_attribs.count)
    item.item_attribs << itemattribs

    ia = ItemAttrib.where(:key => 'test_key', :value => 'test_value')
    assert_not_nil(ia)
    assert_not_empty(ia)
    assert_equal(1, ia.count)
    assert_equal(ia[0].item_id, item['id'])

    item.item_attribs.reload
    assert_equal(3, item.item_attribs.count)
  end

  def test_group_by_id_column_not_by_pk
    grouped_count = ItemAttrib.group(:item_id).count
    assert_equal 2, grouped_count.size
    assert_equal 2, grouped_count[1]
    assert_equal 2, grouped_count[2]
  end
end
