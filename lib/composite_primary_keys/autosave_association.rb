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
  end
end
