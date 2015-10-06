class ItemGroup < ActiveRecord::Base
  self.primary_keys = [:item_group_id, :item_group_name]

  has_and_belongs_to_many :items,
                          :primary_key => 'id',
                          :foreign_key => [:item_group_id, :item_group_name],
                          :association_foreign_key => :item_id
end
