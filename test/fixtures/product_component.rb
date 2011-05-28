class ProductComponent < ActiveRecord::Base

  has_and_belongs_to_many :product_component_roles, :join_table => 'product_roles_components',
    :foreign_key => :product_component_id, :association_foreign_key => [:product_id, :role_num]

end
