class DocumentEvent < ActiveRecord::Base
  set_primary_keys :to_uid, :document_event_id
  self.auto_increment_column = :document_event_id
end