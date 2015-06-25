class Mitten < ActiveRecord::Base
  self.primary_keys = [:left_id, :right_id]
end
