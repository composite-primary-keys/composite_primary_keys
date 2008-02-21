class Restaurant < ActiveRecord::Base
  set_primary_keys :franchise_id, :store_id
  has_and_belongs_to_many :suburbs, 
    :foreign_key => [:franchise_id, :store_id],  
    :association_foreign_key => [:city_id, :suburb_id]
end