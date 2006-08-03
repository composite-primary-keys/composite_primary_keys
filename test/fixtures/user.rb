class User < ActiveRecord::Base
  has_many :readings
  has_many :articles, :through => :readings
end

