class ItemAttrib < ActiveRecord::Base
  self.primary_key = :id
  belongs_to :item, :primary_key => :id, :foreign_key => :item_id
end