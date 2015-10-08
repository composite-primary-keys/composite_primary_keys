class ItemGroup < ActiveRecord::Base
  self.primary_keys = [:item_group_id, :item_group_name]

  has_and_belongs_to_many :items,
                          :foreign_key => [:item_group_id, :item_group_name],
                          :association_foreign_key => :item_id,
                          :association_primary_key => :id
end
