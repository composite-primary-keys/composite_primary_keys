class Item < ActiveRecord::Base
  self.primary_keys = :item_no, :item_size
  has_many :item_attribs, :primary_key => :id, :foreign_key => :item_id
  has_one :item_info, :primary_key => :id, :foreign_key => :item_id

  has_and_belongs_to_many :item_groups,
                          :primary_key => 'id',
                          :foreign_key => :item_id,
                          :association_foreign_key => [:item_group_id, :item_group_name]
end