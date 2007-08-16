class User < ActiveRecord::Base
  has_many :readings
  has_many :articles, :through => :readings
  has_many :comments, :as => :person
end

