class ProductComponentRole < ActiveRecord::Base

  set_primary_keys :product_id, :role_num

  belongs_to :product
  has_and_belongs_to_many :product_components, :join_table => 'product_roles_components',
    :foreign_key => [:product_id, :role_num], :association_foreign_key => :product_component_id

end

