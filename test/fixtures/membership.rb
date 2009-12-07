class Membership < ActiveRecord::Base
  # set_primary_keys *keys - turns on composite key functionality
  set_primary_keys :user_id, :group_id
  belongs_to :user
	belongs_to :group
	has_many :statuses, :class_name => 'MembershipStatus', :foreign_key => [:user_id, :group_id]

  has_many :readings, :primary_key => :user_id, :foreign_key => :user_id
  has_one :reading, :primary_key => :user_id, :foreign_key => :user_id, :order => 'id DESC'
end