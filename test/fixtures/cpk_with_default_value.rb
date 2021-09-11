class CpkWithDefaultValue < ActiveRecord::Base
  self.primary_keys = :record_id, :record_version, :published
end
