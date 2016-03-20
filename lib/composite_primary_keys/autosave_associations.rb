module ActiveRecord
  module AutosaveAssociation
    def save_belongs_to_association(reflection)
      association = association_instance_get(reflection.name)
      record      = association && association.load_target
      if record && !record.destroyed?
        autosave = reflection.options[:autosave]

        if autosave && record.marked_for_destruction?
          self[reflection.foreign_key] = nil
          record.destroy
        elsif autosave != false
          saved = record.save(:validate => !autosave) if record.new_record? || (autosave && record.changed_for_autosave?)

          if association.updated?

            # CPK
            # association_id = record.send(reflection.options[:primary_key] || :id)
#            if reflection.options[:primary_key].to_s == 'id'
#              association_id = record['id']
#            else
#              association_id = record.send(reflection.options[:primary_key] || :id)
#            end

# CPK
# association_id = record.send(reflection.options[:primary_key] || :id)
if reflection.options[:primary_key].to_s == 'id'
  association_id = record['id']
else
  if reflection.options[:primary_key].nil? || !reflection.options[:primary_key].is_a?(Array)
    association_id = record.send(reflection.options[:primary_key] || :id)
  else
    association_id = []
    reflection.options[:primary_key].each do |key|
      association_id << record.send(key)
    end
  end
  #association_id = record.send(reflection.options[:primary_key] || :id)
end


            self[reflection.foreign_key] = association_id
            association.loaded!
          end

          saved if autosave
        end
      end
    end
  end
end
