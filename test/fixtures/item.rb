class Item < ActiveRecord::Base
  self.primary_keys = :item_no, :item_size
  has_many :item_attribs, :primary_key => :id, :foreign_key => :item_id
end