class RoleAssignment < ActiveRecord::Base
  self.primary_keys = :subject, :role, :object
end
