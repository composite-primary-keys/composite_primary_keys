class PkAccount < ActiveRecord::Base
  has_many :pk_users
end
