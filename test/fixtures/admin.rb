class Admin < ActiveRecord::Base
  belongs_to :moderator, :foreign_key => :id, :inverse_of => :admin
  has_one :user, :through => :moderator
end
