class Article < ActiveRecord::Base
  has_many :readings, :dependent => :delete_all
  has_many :users, :through => :readings
end

