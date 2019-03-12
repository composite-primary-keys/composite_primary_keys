class PkUser < ActiveRecord::Base
  self.primary_keys = :id, :pk_account_id

  belongs_to :pk_account
  has_many :pk_posts, foreign_key: [:pk_user_id, :pk_account]
end
