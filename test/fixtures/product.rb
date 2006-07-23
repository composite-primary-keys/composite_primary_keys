class Product < ActiveRecord::Base
	set_primary_key :id  # redundant
	has_many :product_tariffs, :foreign_key => :product_id
	has_many :tariffs, :through => :product_tariffs, :foreign_key => :product_id
end
