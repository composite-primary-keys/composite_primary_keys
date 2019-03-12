class PkPost < ActiveRecord::Base
  belongs_to :pk_user, foreign_key: [:pk_user_id, :pk_account_id]
end
