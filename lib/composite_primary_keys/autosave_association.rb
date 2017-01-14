module ActiveRecord
  module AutosaveAssociation
    private
      # Saves the associated record if it's new or <tt>:autosave</tt> is enabled.
      #
      # In addition, it will destroy the association if it was marked for destruction.
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
              # it will fail to use "#record.send(reflection.options[:primary_key] || :id)" for CPK
              association_id = record.read_attribute(reflection.options[:primary_key] || :id)
              self[reflection.foreign_key] = association_id
              association.loaded!
            end

            saved if autosave
          end
        end
      end

      # Saves the associated record if it's new or <tt>:autosave</tt> is enabled
      # on the association.
      #
      # In addition, it will destroy the association if it was marked for
      # destruction with mark_for_destruction.
      #
      # This all happens inside a transaction, _if_ the Transactions module is included into
      # ActiveRecord::Base after the AutosaveAssociation module, which it does by default.
      def save_has_one_association(reflection)
        association = association_instance_get(reflection.name)
        record      = association && association.load_target

        if record && !record.destroyed?
          autosave = reflection.options[:autosave]

          if autosave && record.marked_for_destruction?
            record.destroy
          elsif autosave != false
            # it will fail to use "#send(reflection.options[:primary_key])" for CPK
            key = reflection.options[:primary_key] ? record.read_attribute(reflection.options[:primary_key]) : id

            if (autosave && record.changed_for_autosave?) || new_record? || record_changed?(reflection, record, key)
              unless reflection.through_reflection
                record[reflection.foreign_key] = key
              end

              saved = record.save(:validate => !autosave)
              raise ActiveRecord::Rollback if !saved && autosave
              saved
            end
          end
        end
      end
  end
end
