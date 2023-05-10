class Moderator < ActiveRecord::Base
  belongs_to :user, :foreign_key => :id, :inverse_of => :moderator
  has_one :admin, :foreign_key => :id, :inverse_of => :moderator
end
