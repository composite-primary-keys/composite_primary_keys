module ActiveRecord
  module AutosaveAssociation
    def save_has_one_association(reflection)
      association = association_instance_get(reflection.name)
      record      = association && association.load_target

      if record && !record.destroyed?
        autosave = reflection.options[:autosave]

        if autosave && record.marked_for_destruction?
          record.destroy
        elsif autosave != false
          # CPK
          #key = reflection.options[:primary_key] ? send(reflection.options[:primary_key]) : id
          key = reflection.options[:primary_key] ? self[reflection.options[:primary_key]] : id

          if (autosave && record.changed_for_autosave?) || new_record? || record_changed?(reflection, record, key)
            unless reflection.through_reflection
              record[reflection.foreign_key] = key
              if inverse_reflection = reflection.inverse_of
                record.association(inverse_reflection.name).loaded!
              end
            end

            saved = record.save(validate: !autosave)
            raise ActiveRecord::Rollback if !saved && autosave
            saved
          end
        end
      end
    end

    def save_belongs_to_association(reflection)
      association = association_instance_get(reflection.name)
      return unless association && association.loaded? && !association.stale_target?

      record = association.load_target
      if record && !record.destroyed?
        autosave = reflection.options[:autosave]

        if autosave && record.marked_for_destruction?
          self[reflection.foreign_key] = nil
          record.destroy
        elsif autosave != false
          saved = record.save(validate: !autosave) if record.new_record? || (autosave && record.changed_for_autosave?)

          if association.updated?
            # CPK
            # association_id = record.send(reflection.options[:primary_key] || :id)
            association_id = reflection.options[:primary_key] ? record[reflection.options[:primary_key]] : record.id
            self[reflection.foreign_key] = association_id
            association.loaded!
          end

          saved if autosave
        end
      end
    end
  end
end
