class Board < ActiveRecord::Base
  self.primary_keys = :board_id, :board_no
end
